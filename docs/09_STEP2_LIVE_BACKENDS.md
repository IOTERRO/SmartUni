<!--
  Author / Project Supervisor : Omar Terro
  GitHub                      : https://github.com/IOTERRO
  Website                     : https://omarterro.fr
  Student (FYP)               : Khaled Othman
  Date                        : 14 October 2026
  Project                     : SmartUni - Smart University CityU
-->

# Step 2 — Live Cloudflare & Firebase backends

This document records the **architecture change from Step 1 (mock data)** to **Step 2 (real cloud APIs)**.  
Use it together with [`03_CODE_AND_ARCHITECTURE_DETAILED.md`](./03_CODE_AND_ARCHITECTURE_DETAILED.md) (folder/file tour) — that file still describes the layered design, but **data sources are now live** as listed below.

---

## 1. What changed (summary)

| Area | Step 1 (design) | Step 2 (now) |
|------|-----------------|--------------|
| Student / admin login | `MockAuthRepository` | `CloudflareAuthRepository` → Users Worker |
| Campus locations / routes | `MockNavigationRepository` + `mock_data.dart` | `CloudflareNavigationRepository` → Navigation Worker |
| Attendance sessions / records | Empty mock lists | `CloudflareAttendanceRepository` → Attendance Worker |
| Student QR | Local rotating token (UI) | Same local generation, but scanner posts to **live** `/api/attendance/scan` |
| Classroom scan | Described only | **New app** `ClassroomScanner/` |
| Parking | `MockParkingRepository` | `FirebaseParkingRepository` ← ESP32 `iot/parking_node` |
| Design banners | `designMode = true` | `designMode = false` |
| Feature flags | mocks always | `AppConfig.useCloudflareApis = true`, `parkingUsesFirebase = true` |

**Architecture pattern did not change:** screens still call `RepositoryHub.instance.*` against abstract repositories.  
**What changed:** which concrete class is constructed inside `RepositoryHub`.

---

## 2. Feature flags (`AppConfig`)

File: `Frontend/lib/core/config/app_config.dart`

```dart
static const bool useCloudflareApis = true;   // auth + navigation + attendance
static const bool parkingUsesFirebase = true; // parking from RTDB
static const bool designMode = false;         // hides yellow design banners
```

To force mocks again for demos without network, set the booleans to `false` and hot-restart.

Secrets stay in gitignored `Frontend/lib/core/config/secrets.dart` (copy from `secrets.example.dart`):

- `usersWorkerApiKey`
- `navigationWorkerApiKey`
- `attendanceWorkerApiKey`
- Firebase web API key + (optional) email/password for RTDB auth

---

## 3. New / important Frontend files (Step 2)

### Shared HTTP layer

| File | Role |
|------|------|
| `lib/data/remote/worker_api_client.dart` | **New.** Thin client: `GET`/`POST`, JSON body, header `X-API-Key`, maps `{ success: false }` → `ApiException` |

All Cloudflare repositories share this class. It is the Flutter equivalent of “call Worker with key”.

### Live repository implementations

| File | Implements | Talks to |
|------|------------|----------|
| `lib/data/repositories/cloudflare_auth_repository.dart` | `AuthRepository` | Users Worker `POST /api/login` |
| `lib/data/repositories/cloudflare_navigation_repository.dart` | `NavigationRepository` | Navigation Worker locations / search / route |
| `lib/data/repositories/attendance_repository.dart` | (+ `CloudflareAttendanceRepository`) | Attendance Worker sessions / records; QR still generated locally |
| `lib/data/repositories/firebase_parking_repository.dart` | `ParkingRepository` | Firebase Auth REST + RTDB `GET /SmartUniversity/Parking.json` |

Mock classes remain in the same files (or sub-impls) so flags can switch back.

### Wiring

File: `lib/data/repositories/repository_hub.dart`

```text
useCloudflareApis ? CloudflareAuthRepository()       : MockAuthRepository()
useCloudflareApis ? CloudflareNavigationRepository() : MockNavigationRepository()
useCloudflareApis ? CloudflareAttendanceRepository() : MockAttendanceRepository()
parkingUsesFirebase ? FirebaseParkingRepository()    : MockParkingRepository()
```

Screens are unchanged at the call site: `RepositoryHub.instance.auth.loginStudent(...)`, etc.

### Models / config touched for live data

| File | Note |
|------|------|
| `lib/core/models/student_qr_payload.dart` | Encodes `SMARTUNI\|SID:\|TOK:\|EXP:` |
| `lib/core/models/parking_slot.dart` | `fromFirebaseJson` for P1/P2/P3 |
| `lib/core/config/app_config.dart` | Worker URLs + Firebase project + poll interval (5s) |
| `lib/features/admin/screens/admin_attendance_screen.dart` | Live sessions / records UI |
| `lib/features/parking/screens/parking_screen.dart` | Polls Firebase on a timer |

---

## 4. Cloudflare Workers (backend)

| Worker script | Deployed URL (example) | D1 binding |
|---------------|------------------------|------------|
| `Backend/worker/users-worker.js` | `https://users.khaledothman750.workers.dev` | `users` |
| `Backend/worker/navigation-worker.js` | `https://navigation.khaledothman750.workers.dev` | `cityu` |
| `Backend/worker/attendance-worker.js` | `https://smart-university.khaledothman750.workers.dev` | `smart-university-db` |

Common rules:

- Header `X-API-Key` must match Worker secret `API_KEY`.
- JSON responses use `{ success, data?, error?, user? }`.
- SQL sources of truth: `docs/sql/*_d1_schema.sql`.
- Manual API proof: `docs/worker_results_tests.md`.

Per-DB guides: [`04`](./04_CLOUDFLARE_ATTENDANCE_DB.md), [`05`](./05_CLOUDFLARE_LOCATIONS_DB.md), [`06`](./06_CLOUDFLARE_USERS_DB.md).

---

## 5. Parking IoT (not Cloudflare)

| Piece | Path |
|-------|------|
| ESP32 firmware | `iot/parking_node/` (was SmartUniArduino; attendance IoT removed) |
| Spots | P1 / P2 / P3 → `/SmartUniversity/Parking/...` |
| Flutter read | `FirebaseParkingRepository` every `parkingRefreshInterval` (5s) |

Attendance is **app QR + ClassroomScanner only** — not Arduino.

---

## 6. Second Flutter app: ClassroomScanner

Step 2 also adds a **dedicated reader**:

| Item | Detail |
|------|--------|
| Folder | `ClassroomScanner/` |
| Deep dive | [`08_CLASSROOM_SCANNER.md`](./08_CLASSROOM_SCANNER.md) |
| Login | Users Worker (admin only) |
| Scan | Attendance Worker `POST /api/attendance/scan` |
| Own `WorkerApiClient` | `ClassroomScanner/lib/data/worker_api_client.dart` (same pattern as Frontend) |

Typical demo: **phone = SmartUni student QR**, **laptop Chrome = ClassroomScanner**.

---

## 7. What is still mock / local / future

| Piece | Status |
|-------|--------|
| Session persistence across app restarts | Still in-memory (`SessionController`) |
| Signed JWT / refresh tokens | Demo token string from login; API key still gates Workers |
| Admin CRUD for users / locations from UI | Partial — many admin screens read live data; full CRUD polish is future |
| Student QR cryptographic signing | Random token + expiry; not HMAC-signed yet |
| Offline mode | Not supported when flags point at live APIs |

---

## 8. Mental model (updated)

1. **`main`** starts SmartUni.  
2. **`RepositoryHub`** picks Cloudflare / Firebase / mock from `AppConfig`.  
3. **`WorkerApiClient`** is the shared HTTP + `X-API-Key` helper for Workers.  
4. **Screens** never call `http` directly — they use repositories.  
5. **Student QR** is generated on-device; **ClassroomScanner** writes attendance.  
6. **Parking** is ESP32 → Firebase → Flutter poll.  

---

*Author / Project Supervisor: Omar Terro — [IOTERRO](https://github.com/IOTERRO) · [omarterro.fr](https://omarterro.fr)*  
*Student (FYP): Khaled Othman*
