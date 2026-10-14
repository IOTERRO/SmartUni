<!--
  Author / Project Supervisor : Omar Terro
  GitHub                      : https://github.com/IOTERRO
  Website                     : https://omarterro.fr
  Student (FYP)               : Khaled Othman
  Date                        : 14 October 2026
  Project                     : SmartUni - Classroom Scanner
-->

# SmartUni Classroom Scanner

Separate Flutter app for the **classroom device**: admin signs in, picks an attendance session, and scans student QRs from the main SmartUni app.

| Role | App |
|------|-----|
| Student | `Frontend/` — shows rotating `SMARTUNI\|SID:…\|TOK:…\|EXP:…` QR |
| Admin / classroom | **This app** — camera → `POST /api/attendance/scan` + success/fail sounds |

**Author / Project Supervisor:** Omar Terro ([IOTERRO](https://github.com/IOTERRO) · [omarterro.fr](https://omarterro.fr))  
**Student (FYP):** Khaled Othman

**Full documentation:** [`docs/08_CLASSROOM_SCANNER.md`](../docs/08_CLASSROOM_SCANNER.md)  
**Step 2 (main app live backends):** [`docs/09_STEP2_LIVE_BACKENDS.md`](../docs/09_STEP2_LIVE_BACKENDS.md)

---

## Setup

```powershell
cd ClassroomScanner
copy lib\core\config\secrets.example.dart lib\core\config\secrets.dart
# Fill usersWorkerApiKey + attendanceWorkerApiKey (same X-API-Key as Frontend)

$env:Path = "C:\Users\<you>\flutter_sdk\flutter\bin;" + $env:Path
flutter pub get
```

Demo admin: `admin` / `admin`.

Worker URLs: `lib/core/config/app_config.dart`.

---

## Run

**Laptop as reader** (phone keeps SmartUni student QR):

```powershell
flutter run -d chrome --web-port=8091
```

**Phone as reader:**

```powershell
flutter run -d <android-device-id>
```

Allow camera when prompted. Unmute the browser tab to hear success / fail beeps.

---

## Flow

1. **Login** → Users Worker `POST /api/login` (admin only)  
2. **Sessions** → Attendance Worker `GET /api/attendance/sessions`  
3. **Scan** → `mobile_scanner` → `POST /api/attendance/scan` with `session_id`, `qr_raw`, `device_id`  
4. **Audio** → `assets/sounds/success.wav` or `fail.wav`

Duplicate scans of the same QR text are ignored for 3 seconds. Expired `EXP` is rejected locally and by the Worker.

If D1 lacks `created_at` on `attendance_records`, see the schema fix in [`docs/08_CLASSROOM_SCANNER.md`](../docs/08_CLASSROOM_SCANNER.md).

---

## Android / iOS

- Android: `INTERNET`, `CAMERA` in `android/app/src/main/AndroidManifest.xml`
- iOS: `NSCameraUsageDescription` in `Info.plist`
- Wireless ADB: [`docs/07_ANDROID_WIRELESS_ADB.md`](../docs/07_ANDROID_WIRELESS_ADB.md)

---

## Structure

```
lib/
├── main.dart
├── app/theme.dart
├── core/          # attribution, app_config, secrets, scan_sounds
├── data/          # WorkerApiClient, ScannerApi
└── features/
    ├── login/
    ├── sessions/
    └── scan/
assets/sounds/     # success.wav, fail.wav
```
