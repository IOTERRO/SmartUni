# Attendance Worker

Paste this into Worker **`smart-university`**  
(because you bound `DB` â†’ **`smart-university-db`** there)

**File:** `attendance-worker.js`

| Item | Value |
|------|--------|
| Worker | `smart-university` |
| URL | `https://smart-university.khaledothman750.workers.dev` |
| D1 binding | `DB` â†’ `smart-university-db` |
| Secret | `API_KEY` = `YOUR_CLOUDFLARE_API_KEY` |

> Note: this Worker is now for **attendance**, not locations.  
> Locations (`cityu`) should use a separate Worker later, or a second D1 binding.

## Deploy

1. Open **smart-university** â†’ **Edit code**
2. Delete old code
3. Paste full contents of `attendance-worker.js`
4. **Save and Deploy**
5. Confirm Settings â†’ Bindings: `DB` = `smart-university-db`
6. Confirm Secret `API_KEY` exists

## Test

```bash
# Health
curl -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" https://smart-university.khaledothman750.workers.dev/api/health

# Courses
curl -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" https://smart-university.khaledothman750.workers.dev/api/courses

# Sessions
curl -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" https://smart-university.khaledothman750.workers.dev/api/attendance/sessions

# Records for your session
curl -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" "https://smart-university.khaledothman750.workers.dev/api/attendance/records?session_id=SES-NET301-20261013-0900"

# Classroom scan (structured)
curl -X POST -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" -H "Content-Type: application/json" \
  -d "{\"session_id\":\"SES-NET301-20261013-0900\",\"student_id\":\"STU-202110318\",\"student_name\":\"Omar Nasser\",\"qr_token\":\"TOK999\",\"device_id\":\"CLASSROOM-CAM-01\"}" \
  https://smart-university.khaledothman750.workers.dev/api/attendance/scan

# Classroom scan (from Flutter QR string)
curl -X POST -H "X-API-Key: YOUR_CLOUDFLARE_API_KEY" -H "Content-Type: application/json" \
  -d "{\"session_id\":\"SES-NET301-20261013-0900\",\"qr_raw\":\"SMARTUNI|SID:STU-202110142|TOK:ABC123|EXP:9999999999999\",\"student_name\":\"Khaled Othman\"}" \
  https://smart-university.khaledothman750.workers.dev/api/attendance/scan
```

## Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| GET | `/api/health` | Service info |
| GET | `/api/courses` | List courses |
| POST | `/api/courses` | Add course |
| GET | `/api/attendance/sessions` | List sessions |
| POST | `/api/attendance/sessions` | Create session |
| GET | `/api/attendance/records?session_id=` | Admin sheet rows |
| POST | `/api/attendance/scan` | Classroom scanner marks Present |
| PUT | `/api/attendance/records/:id` | Edit record |
| DELETE | `/api/attendance/records/:id` | Delete record |
