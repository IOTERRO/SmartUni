<!--
  Author / Project Supervisor : Omar Terro
  GitHub                      : https://github.com/IOTERRO
  Website                     : https://omarterro.fr
  Student (FYP)               : Khaled Othman
  Date                        : 14 October 2026
  Project                     : SmartUni - Smart University CityU
-->
# Cloudflare Attendance DB — What to create

This matches your app flow:

```text
Student Flutter app  →  shows rotating QR (student_id + token + expiry)
Classroom scanner    →  scans QR and POSTs to Worker
Cloudflare D1        →  stores present/absent records
Admin Flutter screen →  reads records by course/session
```

Use **Cloudflare D1** (SQL database), same style as your `locations` table.

| Item | Value |
|------|--------|
| D1 database | `smart-university-db` |
| Worker | `smart-university` |
| Worker URL | `https://smart-university.khaledothman750.workers.dev` |
| Binding | `DB` → `smart-university-db` |
| Worker source | [`Backend/worker/attendance-worker.js`](../Backend/worker/attendance-worker.js) |
| Deploy guide | [`Backend/worker/ATTENDANCE_README.md`](../Backend/worker/ATTENDANCE_README.md) |

---

## 1. Create the database (Dashboard)

1. Go to [Cloudflare Dashboard](https://dash.cloudflare.com) → **Workers & Pages** → **D1**
2. **Create database**
   - Name: `smart-university-db`  
     (or use the same D1 DB where `locations` already exists — recommended)
3. Open the DB → **Console** (SQL editor)
4. Paste and run the SQL from section 3 below

Then bind this D1 database to your Worker (same Worker or a new attendance Worker):

- Worker → **Settings** → **Bindings** → **D1 Database**
- Variable name: `DB` (or whatever your Worker code expects)

---

## 2. Tables you need (3 tables)

| Table | Purpose |
|-------|---------|
| `courses` | List of courses (NET301, CSE210…) for the dropdown |
| `attendance_sessions` | One lecture session (course + date/time + room) |
| `attendance_records` | One row per student in a session (Present/Absent) |

Optional later: `users` table (students/admins). For now you can store `student_id` + `student_name` inside `attendance_records`.

---

## 3. SQL to run in D1 Console

```sql
-- =========================
-- COURSES
-- =========================
CREATE TABLE IF NOT EXISTS courses (
  id            TEXT PRIMARY KEY,          -- e.g. "NET301"
  name          TEXT NOT NULL,             -- e.g. "Smart Networks"
  instructor_id TEXT,                      -- optional for now
  created_at    TEXT NOT NULL DEFAULT (datetime('now'))
);

-- =========================
-- ATTENDANCE SESSIONS
-- One lecture / class meeting
-- =========================
CREATE TABLE IF NOT EXISTS attendance_sessions (
  id            TEXT PRIMARY KEY,          -- e.g. "SES-NET301-20261013-0900"
  course_id     TEXT NOT NULL,             -- FK → courses.id
  session_date  TEXT NOT NULL,             -- "2026-10-13"
  start_time    TEXT NOT NULL,             -- "09:00"
  end_time      TEXT,                      -- "10:30"
  room          TEXT,                      -- "ENG-Lab2"
  is_active     INTEGER NOT NULL DEFAULT 1, -- 1 = open for scanning, 0 = closed
  created_at    TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- =========================
-- ATTENDANCE RECORDS
-- What Admin screen shows (Present / Absent + time)
-- =========================
CREATE TABLE IF NOT EXISTS attendance_records (
  id              INTEGER PRIMARY KEY AUTOINCREMENT,
  session_id      TEXT NOT NULL,           -- FK → attendance_sessions.id
  student_id      TEXT NOT NULL,           -- e.g. "STU-202110142"
  student_name    TEXT NOT NULL,           -- e.g. "Khaled Othman"
  status          TEXT NOT NULL,           -- "Present" | "Absent"
  scanned_at      TEXT,                    -- ISO time when QR was scanned (NULL if Absent)
  qr_token        TEXT,                    -- token from student QR (anti-replay)
  device_id       TEXT,                    -- classroom scanner device id (optional)
  created_at      TEXT NOT NULL DEFAULT (datetime('now')),
  UNIQUE (session_id, student_id),         -- one record per student per session
  FOREIGN KEY (session_id) REFERENCES attendance_sessions(id)
);

CREATE INDEX IF NOT EXISTS idx_att_records_session
  ON attendance_records(session_id);

CREATE INDEX IF NOT EXISTS idx_att_records_student
  ON attendance_records(student_id);
```

---

## 4. Column / key reference (what each field means)

### `courses`

| Key (column) | Type | Example | Required |
|--------------|------|---------|----------|
| `id` | TEXT PK | `NET301` | Yes |
| `name` | TEXT | `Smart Networks` | Yes |
| `instructor_id` | TEXT | `INS001` | No |
| `created_at` | TEXT | auto | Yes |

### `attendance_sessions`

| Key (column) | Type | Example | Required |
|--------------|------|---------|----------|
| `id` | TEXT PK | `SES-NET301-20261013-0900` | Yes |
| `course_id` | TEXT | `NET301` | Yes |
| `session_date` | TEXT | `2026-10-13` | Yes |
| `start_time` | TEXT | `09:00` | Yes |
| `end_time` | TEXT | `10:30` | No |
| `room` | TEXT | `ENG-Lab2` | No |
| `is_active` | INTEGER | `1` or `0` | Yes |
| `created_at` | TEXT | auto | Yes |

### `attendance_records` ← main table for Admin UI

| Key (column) | Type | Example | Required |
|--------------|------|---------|----------|
| `id` | INTEGER PK | `1` | auto |
| `session_id` | TEXT | `SES-NET301-20261013-0900` | Yes |
| `student_id` | TEXT | `STU-202110142` | Yes |
| `student_name` | TEXT | `Khaled Othman` | Yes |
| `status` | TEXT | `Present` or `Absent` | Yes |
| `scanned_at` | TEXT | `2026-10-13T09:05:12Z` | No (null if Absent) |
| `qr_token` | TEXT | `A1B2C3D4E5F6` | No (filled when Present) |
| `device_id` | TEXT | `CLASSROOM-CAM-01` | No |
| `created_at` | TEXT | auto | Yes |

**Important rule:** `UNIQUE (session_id, student_id)`  
→ same student cannot be inserted twice for the same session.

---

## 5. Sample data (same as your Admin preview screen)

```sql
INSERT INTO courses (id, name, instructor_id) VALUES
  ('NET301', 'Smart Networks', 'INS001'),
  ('CSE210', 'Programming II', 'INS002');

INSERT INTO attendance_sessions (
  id, course_id, session_date, start_time, end_time, room, is_active
) VALUES (
  'SES-NET301-20261013-0900',
  'NET301',
  '2026-10-13',
  '09:00',
  '10:30',
  'ENG-Lab2',
  1
);

INSERT INTO attendance_records (
  session_id, student_id, student_name, status, scanned_at, qr_token, device_id
) VALUES
  ('SES-NET301-20261013-0900', 'STU-202110142', 'Khaled Othman', 'Present', '2026-10-13T09:05:00Z', 'TOK111', 'CLASSROOM-CAM-01'),
  ('SES-NET301-20261013-0900', 'STU-202110201', 'Sara Haddad',   'Present', '2026-10-13T09:06:00Z', 'TOK222', 'CLASSROOM-CAM-01'),
  ('SES-NET301-20261013-0900', 'STU-202110318', 'Omar Nasser',   'Absent',  NULL,                   NULL,    NULL),
  ('SES-NET301-20261013-0900', 'STU-202110444', 'Maya Farah',    'Present', '2026-10-13T09:08:00Z', 'TOK333', 'CLASSROOM-CAM-01');
```

Check it:

```sql
SELECT student_id, student_name, status, scanned_at
FROM attendance_records
WHERE session_id = 'SES-NET301-20261013-0900'
ORDER BY scanned_at;
```

---

## 6. What the classroom scanner should send (later API)

When the classroom camera scans a student QR, your Worker will receive something like:

```json
{
  "session_id": "SES-NET301-20261013-0900",
  "student_id": "STU-202110142",
  "student_name": "Khaled Othman",
  "qr_token": "A1B2C3D4E5F6",
  "token_expires_at": 1739000000000,
  "device_id": "CLASSROOM-CAM-01"
}
```

Worker logic (later):

1. Reject if token expired  
2. Reject if token already used  
3. Upsert `attendance_records` → `status = 'Present'`, set `scanned_at`  
4. Students never scanned by end of class stay / become `Absent`

QR format already used in Flutter:

```text
SMARTUNI|SID:STU-202110142|TOK:A1B2C3D4E5F6|EXP:1739000000000
```

---

## 7. Minimum if you want only ONE table first

If you want the smallest possible start:

```sql
CREATE TABLE IF NOT EXISTS attendance_records (
  id            INTEGER PRIMARY KEY AUTOINCREMENT,
  course_id     TEXT NOT NULL,      -- "NET301"
  course_name   TEXT NOT NULL,      -- "Smart Networks"
  session_date  TEXT NOT NULL,      -- "2026-10-13"
  student_id    TEXT NOT NULL,
  student_name  TEXT NOT NULL,
  status        TEXT NOT NULL,      -- Present | Absent
  scanned_at    TEXT,
  qr_token      TEXT,
  UNIQUE (course_id, session_date, student_id)
);
```

The **3-table design** is better long-term (cleaner Admin dropdown + sessions). Prefer that if you can.

---

## 8. Checklist

- [ ] D1 database created (or reuse existing SmartUni DB)
- [ ] Run `CREATE TABLE` SQL
- [ ] Insert sample courses / session / records
- [ ] Bind D1 to Worker as `DB`
- [x] Worker routes: sessions / records / `POST /api/attendance/scan`  
- [x] Flutter: `CloudflareAttendanceRepository` + `ClassroomScanner/` reader app  
  (see [`08_CLASSROOM_SCANNER.md`](./08_CLASSROOM_SCANNER.md), [`09_STEP2_LIVE_BACKENDS.md`](./09_STEP2_LIVE_BACKENDS.md))

You do **not** need to wire the Flutter app yet — create the tables first, then we connect them in the next step.
