<!--
  Author / Project Supervisor : Omar Terro
  GitHub                      : https://github.com/IOTERRO
  Website                     : https://omarterro.fr
  Student (FYP)               : Khaled Othman
  Date                        : 14 October 2026
  Project                     : SmartUni - Smart University CityU
-->
# SmartUni Frontend — How the Actual Code Works (legacy prototype)

> **Status:** historical notes for the **old** `lib/screens` prototype (now in `Frontend/lib/_legacy/`).  
> **Do not use this file for the current app.**  
> Current architecture: [`03_CODE_AND_ARCHITECTURE_DETAILED.md`](./03_CODE_AND_ARCHITECTURE_DETAILED.md) ·  
> Live backends: [`09_STEP2_LIVE_BACKENDS.md`](./09_STEP2_LIVE_BACKENDS.md) ·  
> Scanner: [`08_CLASSROOM_SCANNER.md`](./08_CLASSROOM_SCANNER.md).

---

## 1. Project identity

| Item | Actual value |
|------|----------------|
| App name (package) | `smart_university_cityu` |
| Entry widget | `SmartCampusApp` in `lib/main.dart` |
| UI framework | Flutter / Dart (`sdk: ^3.13.2`) |
| First screen | `LoginScreen` |
| Branding | City University · Abi Samra Campus · “Smart Campus Experience / 2027” |
| Live API base URL | `https://smart-university-api.khaledothman750.workers.dev` |

The app is a **prototype smart-campus client** for four services described in the FYP:

1. Smart Attendance (QR)
2. Smart Parking
3. Campus Navigation
4. Guest / search assistance

---

## 2. What the FYP report designed vs what the code does

The report (FYP595 Rev3) describes a full smart-university platform:

- Four-layer architecture: **User → Application → Network → IoT**
- Roles: **Student, Teacher, Guest, Admin**
- Backend planned as **Firebase** (Auth, Firestore, Realtime Database, Storage, FCM)
- Instructor dashboard + admin dashboard
- Dynamic QR attendance, IoT parking (ESP32 + ultrasonic), GPS/BLE navigation, guest search
- Face verification / proximity checks mentioned as future/security options

**What the code actually implements today:**

| Report intent | Current frontend reality |
|---------------|--------------------------|
| Firebase backend | **Not used.** HTTP client talks to a **Cloudflare Workers** API |
| Role-based home (student / teacher / guest / admin) | Partially started; **routing is incomplete** |
| Student QR scan | `mobile_scanner` is in `pubspec.yaml` but **no scan UI is wired** |
| Teacher creates QR session | Attendance screen can **start a session** and show a `qr_secret` text — not a real QR UI |
| Parking from IoT / Firebase RTDB | Polls `/api/parking` over HTTP (and URL is currently broken — see bugs) |
| Map + GPS navigation | `google_maps_flutter` declared but **unused**; navigation is dropdown + path list |
| Guest search buildings/offices | Guest home shows a navigation card that **only shows a SnackBar** |
| Admin manage users/locations | Admin login is **hardcoded locally**; after login opens a **blank page** |
| Profile from auth user | Profile shows **placeholder** student data |
| Notifications | Not implemented |

**Bottom line:** UI shells and some API calls exist; the app is **not yet a complete or consistent implementation** of the report design.

---

## 3. Folder structure (what matters)

```
Frontend/
├── lib/
│   ├── main.dart                 # App theme + home = LoginScreen
│   ├── services/
│   │   └── api_services.dart     # ApiService #1 (SharedPreferences + REST helpers)
│   └── screens/
│       ├── login.dart            # Login / guest / open admin
│       ├── home.dart             # Logged-in student-style dashboard (ACTIVE)
│       ├── Guesthome.dart        # Guest dashboard (limited)
│       ├── Admin.dart            # Admin login + blank page
│       ├── AdminHome.dart        # Instructor-style dashboard (NOT wired from login)
│       ├── afterlogin.dart       # Older bottom-nav home (ORPHAN / unused)
│       ├── services.dart         # ApiService #2 + ServicesScreen
│       ├── attendance.dart       # Start attendance session
│       ├── parking.dart          # Parking slot list + polling
│       ├── navigation.dart       # From/To route finder
│       └── profile.dart          # Static profile + incomplete logout
├── assets/images/cityu_logo.png
└── pubspec.yaml
```

`Backend/` in this repo currently only has an empty `test.txt` — the real API appears hosted externally on Workers, not in this workspace.

---

## 4. App startup and navigation flow

```text
main.dart
   └─ MaterialApp(home: LoginScreen)

LoginScreen
   ├─ Sign In (API or hardcoded test user)
   │     └─ HomeScreen  (home.dart)     ← always this screen today
   ├─ Continue as Guest
   │     └─ GuestHomeScreen
   └─ Administrator button
         └─ AdminScreen
               └─ (admin/123456789) → AdminBlankPage (empty)
```

### Important routing gaps

1. **Role is saved** after API login (`role` in SharedPreferences via `api_services.dart`), but **never used** to choose Student vs Teacher vs Admin home.
2. `AdminHome.dart` looks like a **teacher/instructor dashboard** (Create QR-Code, View Attendance Sheet, Parking, Navigation) but **login never navigates to it**.
3. `afterlogin.dart` defines another `HomeScreen` with bottom navigation — **not imported by `main.dart` / `login.dart`**. Treat as legacy.

---

## 5. Dependencies (declared vs used)

From `pubspec.yaml`:

| Package | Declared | Used in current screens? |
|---------|----------|---------------------------|
| `http` | Yes | Yes (login, attendance, parking, navigation, services) |
| `shared_preferences` | Yes | Yes (`api_services.dart` only) |
| `mobile_scanner` | Yes | **No** |
| `google_maps_flutter` | Yes | **No** |
| `cupertino_icons` | Yes | Icons only |

---

## 6. Dual `ApiService` problem (critical)

There are **two different classes named `ApiService`**:

### A) `lib/services/api_services.dart` (used by login)

- Base URL: Workers API
- Login / register / logout
- Stores session in **SharedPreferences**: `token`, `role`, `name`, `user_id`
- Helpers: `getLocations`, `getNavigation`, `searchLocations`, `getParking`, `scanAttendance`, `getCourses`, `getRole`, `isGuest`
- Auth header built by reading the token from SharedPreferences

### B) `lib/screens/services.dart` (used by home / navigation / services UI)

- Same base URL
- Static in-memory field: `ApiService.token`
- Generic `get()` / `post()` helpers
- **Never written by login** — login uses class A and SharedPreferences

### What this breaks

`home.dart` (and `AdminHome.dart`) gate services with:

```dart
if (ApiService.token == null || ApiService.token!.isEmpty) { ... }
```

That checks class **B**. Successful login stores the token in SharedPreferences via class **A**, but does **not** set `ApiService.token` on class B.

So after a real API login, the home dashboard may still treat the user as **not logged in** when opening Attendance / Parking / Navigation.

Also: navigation imports `services.dart` and calls `ApiService.get(...)`, so it uses the in-memory token (usually `null`) even though SharedPreferences may have a valid token.

**Professional fix direction (for the next architecture doc):** one API layer, one session model, one place for auth headers.

---

## 7. Screen-by-screen behavior

### 7.1 `main.dart`

- Builds `MaterialApp` with indigo theme and light scaffold background.
- No routes table, no auth bootstrap (does not restore session on cold start).
- Always starts at `LoginScreen`.

### 7.2 `login.dart` — LoginScreen

**UI:** polished navy/gradient branding, CityU logo, email + password, Sign In, Continue as Guest, Administrator button.

**Login logic:**

1. Validates non-empty fields.
2. **Hardcoded bypass:** `12345khaled@gmail.com` / `123456789` → opens `HomeScreen` **without API**.
3. Otherwise calls `ApiService.login` from `api_services.dart`.
4. On success: SnackBar with name/role, then `openHome()` → **always** `HomeScreen` (student-style), regardless of role.
5. Guest → `GuestHomeScreen`.
6. Administrator → `AdminScreen` (separate local login).

**Not implemented:** forgot password (SnackBar placeholder), role-based navigation, session restore.

### 7.3 `home.dart` — logged-in dashboard (active)

- Welcome banner + three service cards: Attendance, Parking, Campus Navigation.
- Profile icon → `ProfileScreen`.
- Back button clears stack to `LoginScreen` (does not call `ApiService.logout()`).
- Service open check uses **wrong** `ApiService.token` (see §6).

### 7.4 `Guesthome.dart`

- Welcome guest UI.
- One card: Campus Navigation — currently only SnackBar *“Campus Navigation selected.”*
- Comment in code: `// Connect your Campus Navigation screen here.`
- Guest **cannot** open parking/search yet, even though report allows public parking + search.

### 7.5 `Admin.dart`

- Local credentials: `admin` / `123456789` (not API).
- Success → `AdminBlankPage` (empty white scaffold).
- Not connected to Workers auth, user management, or campus data.

### 7.6 `AdminHome.dart` (unwired)

- Looks like instructor/admin home: Create QR-Code, View Attendance Sheet, Parking, Navigation.
- Both attendance entries open the same `AttendanceScreen`.
- Same broken `ApiService.token` gate.
- Duplicate class names (`HomeScreen`, `HomeDashboardView`) collide conceptually with `home.dart` / `afterlogin.dart`.

### 7.7 `afterlogin.dart` (orphan)

- Bottom nav: Home / Services / Profile.
- Incomplete dashboard card body.
- Not used by current entry flow.

### 7.8 `services.dart` — ServicesScreen + ApiService #2

- Alternate “Campus Services” listing (QR Attendance, Smart Parking, Campus Navigation).
- Shows SIGNED IN / GUEST based on static `ApiService.token`.
- Also not the primary home path after login (login goes to `home.dart`).

### 7.9 `attendance.dart`

- Loads courses from `GET /api/courses` (**no auth header**).
- Dropdown select course → `POST /api/attendance/session` with hardcoded `"instructor_id": "INS001"`.
- On success shows `qr_secret` as selectable text.
- Missing vs report:
  - Student camera scan (`/api/attendance/scan` exists in `api_services.dart` but unused here)
  - Dynamic QR widget / regeneration
  - Session close + attendance report
  - Role split (teacher start vs student scan)
  - Auth / real instructor id from logged-in user

### 7.10 `parking.dart`

- Polls parking every 3 seconds + pull-to-refresh.
- Shows available/occupied counts and slot list.
- **Bug:** base URL string contains spaces:

  ```dart
  "https:// smart-university-api.khaledothman750.workers.dev "
  ```

  Requests will fail until fixed.
- Does not use shared `ApiService`; duplicates HTTP logic.
- No map/guidance to free slots (report feature).

### 7.11 `navigation.dart`

- Loads locations via `ApiService.get('/api/locations')` (services.dart).
- User picks From / To → `GET /api/navigation?from=&to=`.
- Shows total distance + step list (`name`, `type`, `floor`).
- No Google Map, no GPS, no BLE, no guest search handoff.
- Search API helper exists in `api_services.dart` (`/api/locations/search`) but **no Search screen**.

### 7.12 `profile.dart`

- Static UI: “Student Name”, fake ID/email/faculty.
- Logout dialog exists but only shows SnackBar: *connect your logout action* — does not clear prefs or navigate to login.
- Does not read `name` / `role` from SharedPreferences.

---

## 8. API surface the frontend expects

Base: `https://smart-university-api.khaledothman750.workers.dev`

| Method | Endpoint | Used by |
|--------|----------|---------|
| POST | `/api/login` | `api_services.dart` ← login |
| POST | `/api/register` | `api_services.dart` (no register UI) |
| GET | `/api/locations` | navigation / api_services |
| GET | `/api/navigation?from=&to=` | navigation / api_services |
| GET | `/api/locations/search?q=` | api_services only (no UI) |
| GET | `/api/parking` | parking / api_services |
| POST | `/api/attendance/scan` | api_services only (no UI) |
| GET | `/api/courses` | attendance screen (direct http) |
| POST | `/api/attendance/session` | attendance screen (direct http) |

Auth pattern intended by `api_services.dart`: `Authorization: Bearer <token>`.

Many screens either skip auth or use the wrong token store.

---

## 9. Auth & session model (actual)

```text
Login success (api_services.dart)
  → SharedPreferences:
       token, role, name, user_id

Login hardcode bypass
  → NO SharedPreferences write

Admin login
  → NO SharedPreferences / NO API

Guest
  → NO token (correct for guest)
```

Missing professional pieces:

- Auth bootstrap on app start (auto-login / redirect)
- Secure token storage strategy
- Role → route map
- Central logout that clears session + navigates to login
- 401 handling that forces re-login consistently

---

## 10. State / architecture style today

Current style is **screen-centric**:

- Almost no models (`User`, `Course`, `ParkingSlot`, `Location`)
- Almost no repositories / controllers / providers
- Screens call `http` or `ApiService` directly
- Duplicated colors, cards, and base URLs across files
- Navigation uses imperative `Navigator.push` / `pushReplacement` / `pushAndRemoveUntil`

This is normal for an early FYP prototype, but it is the main reason the app feels inconsistent and hard to extend.

---

## 11. Known bugs / inconsistencies (code-level)

1. **Two `ApiService` classes** with different session storage.
2. **Login token never reaches** the token check used by home/services/navigation.
3. **Parking base URL has spaces** → broken requests.
4. **Hardcoded credentials** in login and admin (dev-only; not production-safe).
5. **Role ignored** after successful API login.
6. **`AdminHome.dart` / `afterlogin.dart` unused or conflicting** with active `home.dart`.
7. **Profile logout not wired**; home “back to login” does not clear session.
8. **Attendance** hardcodes instructor id; no student scan flow.
9. **Guest navigation not connected** to `NavigationScreen`.
10. Declared packages **`mobile_scanner`** and **`google_maps_flutter` unused**.
11. Report says **Firebase**; code uses **Workers HTTP API** — design docs and implementation diverge.
12. No cold-start session restore.

---

## 12. Mapping report roles → current screens

| Role (report) | Expected access | Current app path |
|---------------|-----------------|------------------|
| Student | Login, scan attendance, parking, nav, search | Login → `home.dart` (services gated incorrectly) |
| Teacher | Create QR session, monitor attendance | No dedicated route; attendance UI is instructor-oriented but opened from student home |
| Guest | Map, search, parking, public info | `Guesthome.dart` with unfinished navigation only |
| Admin | Manage users/locations/services | Local admin login → blank page |

---

## 13. How to run / explore the app mentally

1. Open app → branded login.
2. Sign in with API user **or** hardcoded test account → student home cards.
3. Or continue as guest → limited guest home.
4. Or open Administrator → local admin form → blank page.
5. From student home, cards should open Attendance / Parking / Navigation, but auth gating and API bugs often block or fail those flows.

---

## 14. Honest maturity assessment

| Area | Maturity |
|------|----------|
| Visual login / branding | Relatively advanced for a prototype |
| Navigation shell / cards | Basic but usable |
| Unified API + auth | **Broken / duplicated** |
| Role-based UX | **Not implemented** |
| Attendance end-to-end | **Partial (session start only)** |
| Parking live UI | **Partial (polling UI; URL bug)** |
| Navigation | **Partial (list path; no map)** |
| Guest/search | **Mostly missing** |
| Admin portal | **Placeholder only** |
| IoT / Firebase as in report | **Not present in this frontend** |

The codebase is best understood as a **UI prototype + early API integration**, not yet the full smart-campus system described in the FYP report.

---

## 15. What to document next

The next markdown file should cover:

1. Target professional architecture (single API client, session/auth, roles, routing)
2. Align report vision with the real backend choice (Workers API vs Firebase — pick one)
3. Feature backlog per role (Student / Teacher / Guest / Admin)
4. Screen map + data models + folder redesign
5. Priority fixes (token unification, parking URL, wire guest nav, QR scan, admin home)

Suggested filename for the follow-up doc:

`docs/02_TARGET_ARCHITECTURE_AND_FEATURES.md`

---

*Generated from reading `Frontend/lib/**` and `docs/Khaled Othman FYP595 Report Rev3.docx`.*
