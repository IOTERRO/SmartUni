<!--
  Author / Project Supervisor : Omar Terro
  GitHub                      : https://github.com/IOTERRO
  Website                     : https://omarterro.fr
  Student (FYP)               : Khaled Othman
  Date                        : 14 October 2026
  Project                     : SmartUni - Smart University CityU
-->
# Cloudflare Users DB — Architecture alignment

| Item | Value |
|------|--------|
| Worker | `users` |
| Worker URL | `https://users.khaledothman750.workers.dev` |
| D1 database | `users` |
| Binding | `DB` → `users` |
| Secret | `API_KEY` |
| Worker source | [`Backend/worker/users-worker.js`](../Backend/worker/users-worker.js) |
| SQL | [`sql/users_d1_schema.sql`](./sql/users_d1_schema.sql) |
| Flutter use | Student login · Admin login · Admin manage users (later) |

---

## 1. Architecture place

```text
Flutter Auth (StudentLogin / AdminLogin)
        │  Step 2
        ▼
Worker: users.khaledothman750.workers.dev
        │  env.DB
        ▼
D1 database: users  →  table users
```

| Role in app | Stored as |
|-------------|-----------|
| Student | `role = 'student'` (or old `isAdmin = 0`) |
| Admin | `role = 'admin'` (or old `isAdmin = 1`) |
| Guest | no DB row (local session only) |

---

## 2. Recommended table `users`

| Column | Type | Example |
|--------|------|---------|
| `id` | INTEGER PK | `1` |
| `username` | TEXT UNIQUE | `student` / `admin` |
| `password` | TEXT | `student` (hash later) |
| `full_name` | TEXT | `Khaled Othman` |
| `email` | TEXT | `...@st.cityu.edu.lb` |
| `role` | TEXT | `student` \| `admin` |
| `faculty` | TEXT | `Engineering Faculty` |
| `is_active` | INTEGER | `1` |
| `created_at` | TEXT | auto |

Your old fields still work:

- `isAdmin` → Worker maps to `role`
- Worker never returns `password` in GET responses

Run [`sql/users_d1_schema.sql`](./sql/users_d1_schema.sql) in D1 Console.

---

## 3. API endpoints

Header required:

`X-API-Key: <your API_KEY secret>`

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/api/health` | Service info |
| POST | `/api/login` | Student / Admin login |
| GET | `/api/users` | List users (no passwords) |
| GET | `/api/users/:id` | One user |
| POST | `/api/users` | Create user |
| PUT | `/api/users/:id` | Update user |
| DELETE | `/api/users/:id` | Soft/hard delete |

Legacy paths still supported: `GET /`, `POST /`, `DELETE /?id=`

### Login body

```json
{ "username": "student", "password": "student" }
```

### Login response

```json
{
  "success": true,
  "token": "demo-student-1",
  "user": {
    "id": 1,
    "username": "student",
    "full_name": "Khaled Othman",
    "role": "student",
    "email": "202110142@st.cityu.edu.lb",
    "faculty": "Engineering Faculty"
  }
}
```

### Create user body

```json
{
  "username": "sara",
  "password": "pass123",
  "full_name": "Sara Haddad",
  "email": "sara@st.cityu.edu.lb",
  "role": "student",
  "faculty": "Engineering Faculty"
}
```

Legacy still accepted: `{ "username", "password", "isAdmin": 0 }`

---

## 4. Flutter mapping (Step 2)

| API `user` | Flutter `AppUser` |
|------------|-------------------|
| `id` | `id` |
| `full_name` | `displayName` |
| `username` | `identifier` |
| `role` | `UserRole.student` / `admin` |
| `faculty` | `faculty` |
| `email` | `email` |

**Step 2 done:** `CloudflareAuthRepository` calls `POST /api/login` when `AppConfig.useCloudflareApis` is true.  
`ClassroomScanner` also uses the same Users Worker for admin login.  
See [`09_STEP2_LIVE_BACKENDS.md`](./09_STEP2_LIVE_BACKENDS.md).

---

## 5. Deploy checklist

- [x] Worker `users` created  
- [x] Binding `DB` → D1 `users`  
- [x] Secret `API_KEY` set  
- [x] Deploy `Backend/worker/users-worker.js`  
- [x] Schema / seed `student/student` and `admin/admin`  
- [x] Wire Flutter login to `POST /api/login` (`CloudflareAuthRepository`)  
