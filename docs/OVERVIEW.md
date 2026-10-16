<!--
  Author / Project Supervisor : Omar Terro
  GitHub                      : https://github.com/IOTERRO
  Website                     : https://omarterro.fr
  Student (FYP)               : Khaled Othman
  Project                     : SmartUni - Smart University CityU
-->

# SmartUni — Simple overview

**SmartUni** is a Final Year Project for City University · Abi Samra Campus.  
It helps people on campus with three services: **find places**, **take attendance with QR**, and **see parking** that is free or occupied.

| Role | Who | What they use |
|------|-----|----------------|
| **Author / Project Supervisor** | Omar Terro | [IOTERRO](https://github.com/IOTERRO) · [omarterro.fr](https://omarterro.fr) |
| **Student (FYP)** | Khaled Othman | Implements the apps and IoT under supervision |

---

## What the system does

| Service | Idea in one sentence |
|---------|----------------------|
| **Navigation** | Guest or student picks places on campus and gets a route from the cloud map database. |
| **Attendance** | Student shows a QR on their phone; a classroom device scans it and marks them Present. |
| **Parking** | An ESP32 with ultrasonic sensors updates Firebase; the app shows which bays are free. |

---

## Two Flutter apps (why?)

| App | Folder | Used by |
|-----|--------|---------|
| **SmartUni** | `Frontend/` | Guest, student, admin (phone or browser) |
| **Classroom Scanner** | `ClassroomScanner/` | Classroom laptop/phone that **reads** student QRs |

Students keep their phone to show the QR. The scanner is a separate device so the camera stays on the classroom side.

---

## Who can do what

```text
Guest   → Navigation only (no login)
Student → Login → Navigation + Attendance QR + Parking + Profile
Admin   → Login → Oversee navigation, attendance sessions/records, parking IoT
```

Demo logins (D1 seed): `student` / `student` · `admin` / `admin`

---

## Where data lives

```text
SmartUni / Scanner  ──X-API-Key──►  Cloudflare Workers  ──►  D1 SQL databases
   • users login                                              (users, cityu,
   • campus locations                                          smart-university-db)
   • attendance sessions & scans

SmartUni parking    ──HTTPS──────►  Firebase Realtime DB  ◄── ESP32 parking_node
                                      /SmartUniversity/Parking
```

| Topic | Technology |
|-------|------------|
| Login | Cloudflare Worker + D1 `users` |
| Map / routes | Cloudflare Worker + D1 `cityu` |
| Attendance | Cloudflare Worker + D1 `smart-university-db` |
| Parking | Firebase + ESP32 (`iot/parking_node`) |

---

## Attendance in plain words

1. Admin opens a **class session** (in SmartUni admin or seed data).  
2. Student opens **Attendance QR** — the code changes every ~20 seconds.  
3. Classroom Scanner (admin login) picks that session and **scans** the phone.  
4. The Attendance Worker saves **Present** in the database.  
5. Scanner plays a success or fail sound.

QR text looks like: `SMARTUNI|SID:student|TOK:…|EXP:…`

---

## Repository map (high level)

```text
SmartUni/
├── Frontend/           Main campus app
├── ClassroomScanner/   QR reader app
├── Backend/
│   ├── worker/         Cloudflare Workers + API test log
│   └── sql/            D1 schema scripts
├── iot/parking_node/   ESP32 firmware
└── docs/               This overview + detailed architecture
```

---

## Want the full technical story?

Read **[`ARCHITECTURE_DETAILED.md`](./ARCHITECTURE_DETAILED.md)** — folders, every important file, flowcharts, APIs, and how Flutter talks to Cloudflare and Firebase.

Practical extras:

- Wireless phone debugging: [`07_ANDROID_WIRELESS_ADB.md`](./07_ANDROID_WIRELESS_ADB.md)  
- D1 SQL schemas: [`../Backend/sql/`](../Backend/sql/)  
- Worker API test log: [`../Backend/worker/worker_results_tests.md`](../Backend/worker/worker_results_tests.md)
