<!--
  Author / Project Supervisor : Omar Terro
  GitHub                      : https://github.com/IOTERRO
  Website                     : https://omarterro.fr
  Student (FYP)               : Khaled Othman
  Date                        : 14 October 2026
  Project                     : SmartUni - Smart University CityU
-->

# SmartUni — Smart University (CityU)

**Campus mobile + IoT platform** for City University · Abi Samra Campus.  
Final Year Project (FYP) that unifies **campus navigation**, **QR attendance**, and **smart parking** in one Flutter application, backed by Cloudflare Workers / D1 and Firebase Realtime Database with an ESP32 sensor node.

---

## Purpose

SmartUni helps different campus users get the right services without mixing responsibilities:

| Role | What they can do |
|------|------------------|
| **Guest** | Browse campus **navigation** (find buildings / routes) without an account |
| **Student** | Sign in, use **navigation**, show a **rotating attendance QR**, and check **live parking** |
| **Admin** | Sign in and oversee **navigation**, **attendance records**, and **parking IoT** modules |

The goal is a **maintainable, role-based product**: clear architecture in Flutter, real cloud APIs (not only mocks), and a physical IoT layer for parking occupancy.

---

## People

| Role | Name | Links |
|------|------|--------|
| **Author / Project Supervisor** | **Omar Terro** | GitHub: [IOTERRO](https://github.com/IOTERRO) · Website: [omarterro.fr](https://omarterro.fr) |
| **Student (FYP)** | **Khaled Othman** | Repository owner: [khaledothman750-cloud/SmartUni](https://github.com/khaledothman750-cloud/SmartUni) |

Omar Terro supervises the Final Year Project of Khaled Othman.  
See also [`AUTHORS.md`](AUTHORS.md).

---

## System overview

```
┌─────────────────┐     X-API-Key      ┌──────────────────────────┐
│  Flutter app    │ ─────────────────► │ Cloudflare Workers       │
│  (Guest/Student │                    │  • users      → D1 users │
│   /Admin)       │                    │  • navigation → D1 cityu │
│                 │                    │  • attendance → D1 smart │
│                 │     Auth + REST    │    -university-db        │
│                 │ ◄───────────────── │                          │
│                 │                    └──────────────────────────┘
│                 │
│                 │     idToken + GET  ┌──────────────────────────┐
│                 │ ─────────────────► │ Firebase Realtime DB     │
│                 │ ◄───────────────── │ /SmartUniversity/Parking │
└─────────────────┘                    └────────────▲─────────────┘
                                                    │ Wi-Fi + JSON
                                       ┌────────────┴─────────────┐
                                       │ ESP32 parking_node       │
                                       │ 3× HC-SR04 (P1/P2/P3)    │
                                       └──────────────────────────┘
```

### Backend choices

| Module | Technology | Why |
|--------|------------|-----|
| Users / login | Cloudflare Worker + D1 `users` | Central auth for student & admin |
| Campus navigation | Cloudflare Worker + D1 `cityu` (`locations`, `location_edges`) | Graph routing on campus map data |
| Attendance | Cloudflare Worker + D1 `smart-university-db` | Sessions & records; student shows QR in-app; classroom scanner posts scans |
| Parking | Firebase RTDB + ESP32 ultrasonics | Live occupancy from physical sensors |

Attendance is **not** handled by Arduino/IoT anymore — only parking is.

---

## Repository layout

```
SmartUni/
├── AUTHORS.md                 # Supervisor & student credits
├── README.md                  # This file
├── Frontend/                  # Flutter application (roles, UI, repos)
├── Backend/worker/            # Cloudflare Workers (users, navigation, attendance)
├── iot/parking_node/          # ESP32 firmware → Firebase parking
└── docs/                      # Architecture notes, D1 SQL, Worker test results
```

---

## Flutter app (`Frontend/`)

Professional structure:

- `lib/app/` — theme, router, root widget  
- `lib/core/` — config, models, session, shared widgets, attribution  
- `lib/data/repositories/` — contracts + Cloudflare / Firebase implementations  
- `lib/features/` — auth, guest, student, admin, navigation, attendance, parking  

`RepositoryHub` switches live backends on via `AppConfig` (`useCloudflareApis`, `parkingUsesFirebase`).

### Run locally

```powershell
cd Frontend
# Copy secrets.example.dart → secrets.dart and fill API keys / Firebase auth
$env:Path = "C:\Users\<you>\flutter_sdk\flutter\bin;" + $env:Path
flutter pub get
flutter run -d chrome --web-port=8090
```

### Demo accounts (D1 seed)

| Role | Username | Password |
|------|----------|----------|
| Student | `student` | `student` |
| Admin | `admin` | `admin` |

---

## Cloudflare Workers (`Backend/worker/`)

| Worker | URL (example) | D1 binding |
|--------|----------------|------------|
| Users | `https://users.khaledothman750.workers.dev` | `users` |
| Navigation | `https://navigation.khaledothman750.workers.dev` | `cityu` |
| Attendance | `https://smart-university.khaledothman750.workers.dev` | `smart-university-db` |

All APIs expect header `X-API-Key` (stored as Worker secret `API_KEY`).  
SQL schemas: `docs/sql/`. Test log: `docs/worker_results_tests.md`.

---

## IoT parking (`iot/parking_node/`)

ESP32 firmware publishes three bays to Firebase:

| Spot | Label | TRIG | ECHO |
|------|-------|------|------|
| P1 | Front | 13 | 14 |
| P2 | Left | 26 | 27 |
| P3 | Right | 32 | 33 |

Path: `/SmartUniversity/Parking/P1|P2|P3`  
Copy `Config.example.h` → `Config.h` (gitignored) for Wi-Fi and Firebase credentials.  
Details: [`iot/parking_node/README.md`](iot/parking_node/README.md).

The Flutter **Smart Parking** screen polls Firebase every few seconds so ESP updates appear live.

---

## Documentation

| Doc | Content |
|-----|---------|
| [`docs/02_STEP1_DESIGN_ARCHITECTURE.md`](docs/02_STEP1_DESIGN_ARCHITECTURE.md) | Step 1 UI / architecture |
| [`docs/03_CODE_AND_ARCHITECTURE_DETAILED.md`](docs/03_CODE_AND_ARCHITECTURE_DETAILED.md) | Deep dive on Flutter structure |
| [`docs/04_CLOUDFLARE_ATTENDANCE_DB.md`](docs/04_CLOUDFLARE_ATTENDANCE_DB.md) | Attendance D1 |
| [`docs/05_CLOUDFLARE_LOCATIONS_DB.md`](docs/05_CLOUDFLARE_LOCATIONS_DB.md) | Navigation D1 |
| [`docs/06_CLOUDFLARE_USERS_DB.md`](docs/06_CLOUDFLARE_USERS_DB.md) | Users D1 |
| [`docs/worker_results_tests.md`](docs/worker_results_tests.md) | Worker API test results |
| [`docs/07_ANDROID_WIRELESS_ADB.md`](docs/07_ANDROID_WIRELESS_ADB.md) | Run Flutter on a phone over Wi‑Fi ADB |

---

## Security notes

- Never commit `Frontend/lib/core/config/secrets.dart` or `iot/parking_node/Config.h`  
- Use the `*.example` templates and fill secrets locally / in Cloudflare  
- Rotate any keys or tokens that were shared in chat or screenshots  

---

## License / academic use

Academic Final Year Project — City University.  

| | |
|--|--|
| **Author / Project Supervisor** | **Omar Terro** — [github.com/IOTERRO](https://github.com/IOTERRO) · [omarterro.fr](https://omarterro.fr) |
| **Student (FYP)** | **Khaled Othman** |
