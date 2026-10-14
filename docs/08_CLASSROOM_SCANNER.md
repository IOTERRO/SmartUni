<!--
  Author / Project Supervisor : Omar Terro
  GitHub                      : https://github.com/IOTERRO
  Website                     : https://omarterro.fr
  Student (FYP)               : Khaled Othman
  Date                        : 14 October 2026
  Project                     : SmartUni - Classroom Scanner
-->

# Classroom Scanner — How the reader app works

This document explains the **separate Flutter app** in `ClassroomScanner/`: the classroom device that scans student attendance QRs and writes **Present** rows into Cloudflare D1 via the Attendance Worker.

Related:

| Doc | Role |
|-----|------|
| [`ClassroomScanner/README.md`](../ClassroomScanner/README.md) | Quick setup |
| [`09_STEP2_LIVE_BACKENDS.md`](./09_STEP2_LIVE_BACKENDS.md) | Main app mock → live Cloudflare/Firebase |
| [`04_CLOUDFLARE_ATTENDANCE_DB.md`](./04_CLOUDFLARE_ATTENDANCE_DB.md) | D1 schema |
| [`Backend/worker/ATTENDANCE_README.md`](../Backend/worker/ATTENDANCE_README.md) | Worker endpoints |

---

## 1. Why a second app?

| App | Who uses it | Job |
|-----|-------------|-----|
| `Frontend/` (SmartUni) | Guest / student / admin on phone or web | Student **shows** a rotating QR |
| `ClassroomScanner/` | Classroom laptop / tablet / phone | Device **reads** the QR and posts to the API |

Keeping the scanner separate means:

- The student’s phone is not also the camera (awkward in class).
- The reader can stay logged in as admin for the whole session.
- Camera permissions and UI stay focused on one job: scan → beep → next student.

---

## 2. End-to-end attendance flow

```text
┌──────────────────────┐         ┌─────────────────────────────┐
│ SmartUni (Frontend)  │         │ ClassroomScanner (this app) │
│ Student QR screen    │         │ Login → Session → Camera    │
└──────────┬───────────┘         └──────────────┬──────────────┘
           │ shows QR                          │
           │ SMARTUNI|SID:…|TOK:…|EXP:…        │
           │                                    │ POST /api/attendance/scan
           │                                    │  session_id + qr_raw
           │                                    ▼
           │                         ┌──────────────────────────┐
           │                         │ Attendance Worker        │
           │                         │ smart-university.….dev   │
           │                         └────────────┬─────────────┘
           │                                      │ upsert Present
           │                                      ▼
           │                         ┌──────────────────────────┐
           └─────────────────────────│ D1 smart-university-db   │
                 (admin sheet also   │ attendance_records       │
                  reads this)        └──────────────────────────┘
```

1. Admin creates / opens a session in SmartUni admin attendance (or seed data exists).
2. Student opens **Attendance QR** in SmartUni; code refreshes every ~20s.
3. Classroom device runs ClassroomScanner, signs in as **admin**, picks that session.
4. Camera reads the QR → Worker parses `qr_raw` → marks student **Present**.
5. Success / fail sound plays; banner shows the result.

The QR is **not** pre-registered in D1. The Worker trusts the current `SID` + `TOK` + `EXP` in the payload (and rejects expired `EXP`).

---

## 3. QR payload format

Generated in `Frontend` by `StudentQrPayload` / `CloudflareAttendanceRepository.generateStudentQr`:

```text
SMARTUNI|SID:<studentId>|TOK:<randomHex>|EXP:<epochMs>
```

| Field | Meaning |
|-------|---------|
| `SID` | Student identifier (usually university username) |
| `TOK` | Random token for this rotation window |
| `EXP` | Absolute expiry in milliseconds (`DateTime.now().millisecondsSinceEpoch` + refresh interval) |

Example:

```text
SMARTUNI|SID:student|TOK:A1B2C3D4E5F6|EXP:1760457600000
```

Scanner local check (`StudentQrRaw.tryParse`): if `EXP` is already past, fail immediately with “QR expired” (Worker would also reject).

---

## 4. App architecture (layers)

```text
features/          UI screens (login, sessions, scan)
    ↓
data/ScannerApi    Domain API (login, fetchSessions, submitScan)
    ↓
data/WorkerApiClient   HTTP + X-API-Key + JSON decode
    ↓
Cloudflare Workers (users + attendance)
```

Same idea as the main app’s `WorkerApiClient`, but **no** `RepositoryHub` / mock layer — this app is always live against Cloudflare.

### Folder map

```text
ClassroomScanner/
├── lib/
│   ├── main.dart                 # ClassroomScannerApp → LoginScreen
│   ├── app/theme.dart            # Navy / teal Material 3 theme
│   ├── core/
│   │   ├── attribution.dart
│   │   ├── scan_sounds.dart      # success.wav / fail.wav via audioplayers
│   │   └── config/
│   │       ├── app_config.dart   # Worker URLs, device_id
│   │       ├── secrets.dart      # gitignored API keys
│   │       └── secrets.example.dart
│   ├── data/
│   │   ├── worker_api_client.dart
│   │   └── scanner_api.dart      # ScannerUser, AttendanceSession, ScanResult
│   └── features/
│       ├── login/login_screen.dart
│       ├── sessions/session_list_screen.dart
│       └── scan/scan_screen.dart # mobile_scanner + feedback
├── assets/sounds/
│   ├── success.wav
│   └── fail.wav
└── README.md
```

---

## 5. Screen-by-screen

### 5.1 Login (`LoginScreen`)

- Calls `ScannerApi.loginInstructor` → Users Worker `POST /api/login`.
- Requires `role == admin` (students are rejected with a clear message).
- On success → `SessionListScreen` (replacement navigation).

Demo: `admin` / `admin` (D1 seed).

### 5.2 Session list (`SessionListScreen`)

- `GET /api/attendance/sessions` → list of `AttendanceSession`.
- Tap a row → `ScanScreen` for that `session.id`.
- Refresh / sign-out actions in the app bar.

Sessions are normally created from SmartUni **Admin → Attendance**. If the list is empty, create a session there first.

### 5.3 Scan (`ScanScreen`)

- `MobileScanner` (QR only), optional torch, viewfinder overlay.
- On detect:
  1. Ignore duplicates of the same raw string for **3 seconds**.
  2. Optional local expiry check on `EXP`.
  3. `POST /api/attendance/scan` with:
     - `session_id`
     - `qr_raw` (full SMARTUNI string)
     - `device_id` from `AppConfig.scannerDeviceId` (`CLASSROOM-SCANNER-01`)
  4. Update OK / Fail counters + banner.
  5. Play **success** or **fail** beep (`ScanSounds`).

Works on **Chrome** (laptop as reader) and **Android** (phone as reader). Web needs camera permission in the browser tab.

---

## 6. APIs used

| Step | Worker | Method | Path |
|------|--------|--------|------|
| Login | users | POST | `/api/login` |
| Sessions | attendance | GET | `/api/attendance/sessions` |
| Scan | attendance | POST | `/api/attendance/scan` |

All requests send header `X-API-Key` (from local `secrets.dart`).

### Scan body (what the Worker expects)

```json
{
  "session_id": "SES-NET301-20261013-0900",
  "qr_raw": "SMARTUNI|SID:student|TOK:ABC|EXP:9999999999999",
  "device_id": "CLASSROOM-SCANNER-01"
}
```

Worker parses `qr_raw`, checks session is active, checks `EXP`, upserts `attendance_records` with `status = Present`.

### Schema note

The Worker `INSERT` includes a `created_at` column. If D1 was created from an older schema without that column, scans fail with:

```text
D1_ERROR: table attendance_records has no column named created_at
```

Fix in D1 Studio (SQLite does not allow `DEFAULT (datetime('now'))` on `ALTER`):

```sql
ALTER TABLE attendance_records ADD COLUMN created_at TEXT DEFAULT '';
UPDATE attendance_records
SET created_at = COALESCE(scanned_at, datetime('now'))
WHERE created_at IS NULL OR created_at = '';
```

Canonical schema: [`docs/sql/attendance_d1_schema.sql`](./sql/attendance_d1_schema.sql).

---

## 7. Config & secrets

| File | Contents |
|------|----------|
| `lib/core/config/app_config.dart` | `usersWorkerUrl`, `attendanceWorkerUrl`, `scannerDeviceId` |
| `lib/core/config/secrets.dart` | `usersWorkerApiKey`, `attendanceWorkerApiKey` (**gitignored**) |
| `secrets.example.dart` | Template committed to git |

Use the **same** `API_KEY` values as `Frontend/lib/core/config/secrets.dart`.

---

## 8. Dependencies

| Package | Why |
|---------|-----|
| `http` | REST to Workers |
| `mobile_scanner` | Camera QR decode (web + Android) |
| `audioplayers` | Success / fail WAV assets |

Android permissions: `INTERNET`, `CAMERA` in `android/app/src/main/AndroidManifest.xml`.  
iOS: `NSCameraUsageDescription` in `Info.plist`.

---

## 9. How to run

### Laptop as reader (recommended for demos)

```powershell
cd ClassroomScanner
# secrets.dart already filled locally
$env:Path = "C:\Users\<you>\flutter_sdk\flutter\bin;" + $env:Path
flutter pub get
flutter run -d chrome --web-port=8091
```

Allow camera when Chrome prompts. Keep SmartUni student QR on the phone (`Frontend` on device).

### Phone as reader

```powershell
flutter run -d <android-device-id>
```

Wireless ADB: [`07_ANDROID_WIRELESS_ADB.md`](./07_ANDROID_WIRELESS_ADB.md).

---

## 10. Troubleshooting

| Symptom | Likely cause |
|---------|----------------|
| “Missing API key” | `secrets.dart` still has `PASTE_KEY_HERE` |
| Login fails for student | Scanner allows **admin only** |
| No sessions | Create session in SmartUni admin attendance |
| `created_at` D1 error | Run ALTER above |
| QR expired | Wait for student QR to refresh (~20s) |
| No sound on web | Unmute the browser tab; click once in the page first |
| Camera black on web | Grant camera permission; prefer `localhost` (already used) |

---

## 11. What this app does **not** do

- Does not generate student QRs (that is `Frontend`).
- Does not manage parking or navigation.
- Does not use Firebase.
- Does not keep a long-lived JWT (login is a gate; scans use the shared API key like other Workers).

---

*Author / Project Supervisor: Omar Terro — [IOTERRO](https://github.com/IOTERRO) · [omarterro.fr](https://omarterro.fr)*  
*Student (FYP): Khaled Othman*
