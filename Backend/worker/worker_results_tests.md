<!--
  Author / Project Supervisor : Omar Terro
  GitHub                      : https://github.com/IOTERRO
  Website                     : https://omarterro.fr
  Student (FYP)               : Khaled Othman
  Date                        : 14 October 2026
  Project                     : SmartUni - Smart University CityU
-->
# Cloudflare Workers — Test Commands & Results

Lives next to the Workers under `Backend/worker/`.  
Schemas: [`../sql/`](../sql/). System docs: [`../../docs/OVERVIEW.md`](../../docs/OVERVIEW.md) · [`../../docs/ARCHITECTURE_DETAILED.md`](../../docs/ARCHITECTURE_DETAILED.md).

This document records the **PowerShell** tests run against the 3 SmartUni Workers  
(company blocks `curl`, so we use `Invoke-RestMethod`).

**Tested on:** 2026-10-14  
**Auth header used for all requests:**

```powershell
$headers = @{
  "X-API-Key" = "YOUR_CLOUDFLARE_API_KEY"
}
$jsonHeaders = $headers + @{ "Content-Type" = "application/json" }
```

---

## Overview of the 3 Workers

| Worker | URL | D1 Database | Binding | Purpose |
|--------|-----|-------------|---------|---------|
| **users** | `https://users.khaledothman750.workers.dev` | `users` | `DB` | Login + user CRUD |
| **navigation** | `https://navigation.khaledothman750.workers.dev` | `cityu` | `DB` | Locations + routes |
| **smart-university** | `https://smart-university.khaledothman750.workers.dev` | `smart-university-db` | `DB` | Attendance (courses/sessions/records/scan) |

```text
Flutter App (later)
   â”œâ”€â”€ users Worker        â†’ D1 users
   â”œâ”€â”€ navigation Worker   â†’ D1 cityu (locations + location_edges)
   â””â”€â”€ attendance Worker   â†’ D1 smart-university-db
```

Every endpoint (except CORS `OPTIONS`) requires:

```http
X-API-Key: <API_KEY secret>
```

---

# 1) Users Worker

**Source:** `Backend/worker/users-worker.js`  
**What it proves:** auth + listing users without exposing passwords.

---

### 1.1 Health check

**Why:** confirms Worker is deployed and bound to the correct DB.

**Command:**

```powershell
Invoke-RestMethod -Uri "https://users.khaledothman750.workers.dev/api/health" -Headers $headers
```

**Response:**

```json
{
  "success": true,
  "service": "users",
  "database": "users",
  "endpoints": [
    "POST /api/login",
    "GET /api/users",
    "GET /api/users/:id",
    "POST /api/users",
    "PUT /api/users/:id",
    "DELETE /api/users/:id"
  ]
}
```

**Explanation:** `service: users` and `database: users` mean this Worker is the auth service and talks to the `users` D1 database.

---

### 1.2 List all users

**Why:** Admin needs a user list; passwords must never be returned.

**Command:**

```powershell
Invoke-RestMethod -Uri "https://users.khaledothman750.workers.dev/api/users" -Headers $headers
```

**Response (summary):** 6 users returned â€” `student`, `admin`, `khaled`, `omarM3alme`, `ibrahim`, `Raed`.  
Each item includes `id`, `username`, `full_name`, `email`, `role`, `faculty`, `is_active`, `created_at`.  
**No `password` field** in any row.

**Explanation:** Safe for Admin UI. Roles are `student` or `admin`, which match Flutter `UserRole`.

---

### 1.3 Login â€” student

**Why:** Flutter Student Login will call this.

**Command:**

```powershell
$body = @{ username = "student"; password = "student" } | ConvertTo-Json
Invoke-RestMethod `
  -Uri "https://users.khaledothman750.workers.dev/api/login" `
  -Headers $jsonHeaders `
  -Method POST `
  -Body $body
```

**Response:**

```json
{
  "success": true,
  "user": {
    "id": 1,
    "username": "student",
    "full_name": "Khaled Othman",
    "email": "202110142@st.cityu.edu.lb",
    "role": "student",
    "faculty": "Engineering Faculty",
    "is_active": 1,
    "created_at": "2026-10-14 07:15:41"
  },
  "token": "demo-student-1"
}
```

**Explanation:** Valid credentials â†’ returns public user profile + a demo token (replace with real JWT later). Flutter maps this to `AppUser` and opens Student Home.

---

### 1.4 Login â€” admin

**Why:** Flutter Admin Login will call this.

**Command:**

```powershell
$body = @{ username = "admin"; password = "admin" } | ConvertTo-Json
Invoke-RestMethod `
  -Uri "https://users.khaledothman750.workers.dev/api/login" `
  -Headers $jsonHeaders `
  -Method POST `
  -Body $body
```

**Response:**

```json
{
  "success": true,
  "user": {
    "id": 2,
    "username": "admin",
    "full_name": "Campus Administrator",
    "email": "admin@cityu.edu.lb",
    "role": "admin",
    "faculty": "Administration",
    "is_active": 1,
    "created_at": "2026-10-14 07:15:41"
  },
  "token": "demo-admin-2"
}
```

**Explanation:** Same login endpoint; `role: admin` tells the app to open Admin Home / DB modules.

---

### 1.5 Login â€” wrong password

**Why:** security check â€” reject bad credentials.

**Command:**

```powershell
$body = @{ username = "student"; password = "wrong" } | ConvertTo-Json
Invoke-RestMethod `
  -Uri "https://users.khaledothman750.workers.dev/api/login" `
  -Headers $jsonHeaders `
  -Method POST `
  -Body $body
```

**Response:**

```text
HTTP 401
{"success":false,"error":"Invalid username or password"}
```

**Explanation:** Correct behavior. Flutter should show an error SnackBar and stay on the login screen.

---

### 1.6 Get one user by id

**Why:** profile / admin detail view.

**Command:**

```powershell
Invoke-RestMethod -Uri "https://users.khaledothman750.workers.dev/api/users/1" -Headers $headers
```

**Response:**

```json
{
  "success": true,
  "data": {
    "id": 1,
    "username": "student",
    "full_name": "Khaled Othman",
    "email": "202110142@st.cityu.edu.lb",
    "role": "student",
    "faculty": "Engineering Faculty",
    "is_active": 1,
    "created_at": "2026-10-14 07:15:41"
  }
}
```

**Explanation:** Single-user fetch works; still no password exposed.

---

# 2) Navigation Worker

**Source:** `Backend/worker/navigation-worker.js`  
**What it proves:** campus directory + shortest-path routing over `location_edges`.

---

### 2.1 Health check

**Command:**

```powershell
Invoke-RestMethod -Uri "https://navigation.khaledothman750.workers.dev/api/health" -Headers $headers
```

**Response:**

```json
{
  "success": true,
  "service": "navigation",
  "database": "cityu",
  "endpoints": [
    "GET /api/locations",
    "GET /api/locations/search?q=",
    "GET /api/navigation?from=&to=",
    "POST /api/locations",
    "PUT /api/locations/:id",
    "DELETE /api/locations/:id"
  ]
}
```

**Explanation:** Confirms this Worker serves navigation and is bound to D1 `cityu`.

---

### 2.2 List locations

**Why:** Guest/Student Navigation dropdown + campus directory.

**Command:**

```powershell
Invoke-RestMethod -Uri "https://navigation.khaledothman750.workers.dev/api/locations" -Headers $headers
```

**Response (summary):** 5 locations:

| id | code | name |
|----|------|------|
| 1 | CITYU | City University Campus |
| 2 | ADMIN | Administration |
| 3 | LIB | Central Library |
| 4 | KABA | King Abdallah Bin AbduAziz |
| 5 | SHOUMAN | SHOUMAN Building |

Each includes `description`, `type`, `floor`, `latitude`, `longitude`, `is_active`.

**Explanation:** Matches your `locations` table. Flutter `CampusLocation` will map these fields.

---

### 2.3 Search locations

**Why:** Guest/Student search box.

**Command:**

```powershell
Invoke-RestMethod -Uri "https://navigation.khaledothman750.workers.dev/api/locations/search?q=lib" -Headers $headers
```

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": 3,
      "code": "LIB",
      "name": "Central Library",
      "description": "Central Library",
      "type": "library",
      "floor": 0,
      "latitude": 34.4182,
      "longitude": 35.8357,
      "is_active": 1
    }
  ]
}
```

**Explanation:** Filter works on name/code/description (`lib` â†’ Central Library).

---

### 2.4 Find route by location ids (`from=2&to=4`)

**Why:** core navigation feature using Dijkstra on `location_edges`.

**Command:**

```powershell
Invoke-RestMethod -Uri "https://navigation.khaledothman750.workers.dev/api/navigation?from=2&to=4" -Headers $headers
```

**Response:**

```json
{
  "success": true,
  "total_distance": 100,
  "path": [
    { "id": 2, "code": "ADMIN", "name": "Administration" },
    { "id": 3, "code": "LIB", "name": "Central Library" },
    { "id": 4, "code": "KABA", "name": "King Abdallah Bin AbduAziz" }
  ]
}
```

**Explanation:**  
ADMIN â†’ LIB (70 m) + LIB â†’ KABA (30 m) = **100 m**.  
Path is the shortest walk using your edges graph.

---

### 2.5 Find route by location codes (`from=ADMIN&to=LIB`)

**Why:** same API can accept `id` or `code`.

**Command:**

```powershell
Invoke-RestMethod -Uri "https://navigation.khaledothman750.workers.dev/api/navigation?from=ADMIN&to=LIB" -Headers $headers
```

**Response:**

```json
{
  "success": true,
  "total_distance": 70,
  "path": [
    { "id": 2, "code": "ADMIN", "name": "Administration" },
    { "id": 3, "code": "LIB", "name": "Central Library" }
  ]
}
```

**Explanation:** Direct edge ADMIN â†” LIB = **70 m**. Codes are resolved to ids inside the Worker.

---

# 3) Attendance Worker (`smart-university`)

**Source:** `Backend/worker/attendance-worker.js`  
**What it proves:** courses / sessions / attendance sheet / classroom scan API.

---

### 3.1 Health check

**Command:**

```powershell
Invoke-RestMethod -Uri "https://smart-university.khaledothman750.workers.dev/api/health" -Headers $headers
```

**Response:**

```json
{
  "success": true,
  "service": "attendance",
  "database": "smart-university-db",
  "endpoints": [
    "GET /api/courses",
    "POST /api/courses",
    "GET /api/attendance/sessions",
    "POST /api/attendance/sessions",
    "GET /api/attendance/records?session_id=",
    "POST /api/attendance/scan",
    "PUT /api/attendance/records/:id",
    "DELETE /api/attendance/records/:id"
  ]
}
```

**Explanation:** This Worker is attendance-only and uses D1 `smart-university-db` (not `cityu`).

---

### 3.2 List courses

**Why:** Admin / session creation dropdown.

**Command:**

```powershell
Invoke-RestMethod -Uri "https://smart-university.khaledothman750.workers.dev/api/courses" -Headers $headers
```

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "CSE210",
      "name": "Programming II",
      "instructor_id": "INS002",
      "created_at": "2026-10-14 07:10:59"
    },
    {
      "id": "NET301",
      "name": "Smart Networks",
      "instructor_id": "INS001",
      "created_at": "2026-10-14 07:10:59"
    }
  ]
}
```

**Explanation:** Matches lowercase `courses` table. `NET301` links to your attendance session.

---

### 3.3 List attendance sessions

**Why:** choose which lecture sheet to open.

**Command:**

```powershell
Invoke-RestMethod -Uri "https://smart-university.khaledothman750.workers.dev/api/attendance/sessions" -Headers $headers
```

**Response:**

```json
{
  "success": true,
  "data": [
    {
      "id": "SES-NET301-20261013-0900",
      "course_id": "NET301",
      "session_date": "2026-10-13",
      "start_time": "09:00",
      "end_time": "10:30",
      "room": "ENG-Lab2",
      "is_active": 1,
      "created_at": "2026-10-14 06:59:15"
    }
  ]
}
```

**Explanation:** One active lecture session for Smart Networks. `is_active = 1` means scanning is allowed.

---

### 3.4 List attendance records (Admin sheet)

**Why:** fills Admin Attendance UI (Present / Absent list).

**Command:**

```powershell
Invoke-RestMethod `
  -Uri "https://smart-university.khaledothman750.workers.dev/api/attendance/records?session_id=SES-NET301-20261013-0900" `
  -Headers $headers
```

**Response (summary):**

| id | student | status | scanned_at | qr_token |
|----|---------|--------|------------|----------|
| 1 | Khaled Othman | Present | `2026-10-13T09:05:00Z` | TOK111 |
| 2 | Sara Haddad | Present | `2026-10-13T09:06:00Z` | TOK222 |
| 4 | Maya Farah | Present | `2026-10-13T09:08:00Z` | TOK333 |
| 3 | Omar Nasser | Absent | `null` | `null` |

**Explanation:**  
- Present students have time + token.  
- Absent student has `NULL` for `scanned_at` / `qr_token` â€” correct.  
- All rows share the same `session_id`.

---

### 3.5 Classroom scan (tested earlier)

**Why:** classroom camera app will call this when a student shows their rotating QR.

**Command example:**

```powershell
$body = @{
  session_id   = "SES-NET301-20261013-0900"
  student_id   = "STU-202110318"
  student_name = "Omar Nasser"
  qr_token     = "TOK-TEST-123"
  device_id    = "CLASSROOM-CAM-01"
} | ConvertTo-Json

Invoke-RestMethod `
  -Uri "https://smart-university.khaledothman750.workers.dev/api/attendance/scan" `
  -Headers $jsonHeaders `
  -Method POST `
  -Body $body
```

**Observed behavior (earlier test):** Omar changed from Absent â†’ Present with a new `scanned_at` timestamp.  
He was set back to Absent afterward with:

```powershell
$body = @{ status = "Absent"; scanned_at = $null; qr_token = $null } | ConvertTo-Json
Invoke-RestMethod `
  -Uri "https://smart-university.khaledothman750.workers.dev/api/attendance/records/3" `
  -Headers $jsonHeaders `
  -Method PUT `
  -Body $body
```

**Explanation:** Scan upserts the student row for that session as Present. Flutter student QR format also supported via `qr_raw`:

```text
SMARTUNI|SID:STU-202110142|TOK:ABC123|EXP:9999999999999
```

---

# 4) How to re-run all tests yourself (PowerShell)

```powershell
$headers = @{
  "X-API-Key" = "YOUR_CLOUDFLARE_API_KEY"
}
$jsonHeaders = $headers + @{ "Content-Type" = "application/json" }

# USERS
Invoke-RestMethod "https://users.khaledothman750.workers.dev/api/health" -Headers $headers
Invoke-RestMethod "https://users.khaledothman750.workers.dev/api/users" -Headers $headers
Invoke-RestMethod "https://users.khaledothman750.workers.dev/api/login" -Headers $jsonHeaders -Method POST -Body (@{username="student";password="student"} | ConvertTo-Json)
Invoke-RestMethod "https://users.khaledothman750.workers.dev/api/login" -Headers $jsonHeaders -Method POST -Body (@{username="admin";password="admin"} | ConvertTo-Json)

# NAVIGATION
Invoke-RestMethod "https://navigation.khaledothman750.workers.dev/api/health" -Headers $headers
Invoke-RestMethod "https://navigation.khaledothman750.workers.dev/api/locations" -Headers $headers
Invoke-RestMethod "https://navigation.khaledothman750.workers.dev/api/locations/search?q=lib" -Headers $headers
Invoke-RestMethod "https://navigation.khaledothman750.workers.dev/api/navigation?from=2&to=4" -Headers $headers
Invoke-RestMethod "https://navigation.khaledothman750.workers.dev/api/navigation?from=ADMIN&to=LIB" -Headers $headers

# ATTENDANCE
Invoke-RestMethod "https://smart-university.khaledothman750.workers.dev/api/health" -Headers $headers
Invoke-RestMethod "https://smart-university.khaledothman750.workers.dev/api/courses" -Headers $headers
Invoke-RestMethod "https://smart-university.khaledothman750.workers.dev/api/attendance/sessions" -Headers $headers
Invoke-RestMethod "https://smart-university.khaledothman750.workers.dev/api/attendance/records?session_id=SES-NET301-20261013-0900" -Headers $headers
```

---

# 5) Final status

| Worker | Health | Core APIs | Ready for Flutter Step 2 |
|--------|--------|-----------|---------------------------|
| users | OK | login + list users | Yes |
| navigation | OK | locations + search + route | Yes |
| attendance (`smart-university`) | OK | courses + sessions + records + scan | Yes |

**Status update:** Flutter apps use live Cloudflare + Firebase; `ClassroomScanner/` posts to `/api/attendance/scan`. See [`ARCHITECTURE_DETAILED.md`](./ARCHITECTURE_DETAILED.md) and [`OVERVIEW.md`](./OVERVIEW.md).
