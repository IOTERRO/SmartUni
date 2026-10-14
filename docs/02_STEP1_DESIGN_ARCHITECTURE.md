# Step 1 — Professional structure & design screens

## Goal

Deliver a **scalable, maintainable Flutter architecture** and **complete UI flows** for Guest / Student / Admin so you can walk through every screen **before** wiring real backend actions.

Old prototype screens were moved to `Frontend/lib/_legacy/` (reference only).

---

## Product decisions locked in this step

| Area | Decision |
|------|----------|
| Roles | **Guest** · **Student** · **Admin** (whiteboard) |
| Guest | **Navigation only** |
| Student | **Navigation + Attendance QR + Parking** |
| Admin | Module views for **Navigation / Attendance / Parking** |
| Navigation backend | Cloudflare Worker + `locations` table |
| Attendance backend | Cloudflare (table not ready yet). Student shows **rotating personal QR**; classroom uses a **separate scanner app** |
| Parking backend | **Firebase** (IoT sensors push live occupancy) |
| Users backend | Cloudflare (not ready yet) → mock login in Step 1 |

---

## Folder structure

```
lib/
  main.dart
  app/
    smart_uni_app.dart
    theme/          # colors + ThemeData
    router/         # named routes
  core/
    config/         # AppConfig + secrets.example
    constants/
    enums/          # UserRole
    models/         # AppUser, locations, parking, QR payload
    session/        # SessionController
    widgets/        # reusable UI
  data/
    mock/           # design sample data
    repositories/   # abstract contracts + Mock* implementations
  features/
    auth/ guest/ student/ admin/
    navigation/ attendance/ parking/
  _legacy/          # previous screens (unused)
```

### OOP / maintainability patterns used

- **Feature folders** by domain
- **Models** as immutable data classes
- **Repository interfaces** + mock implementations (`RepositoryHub`)
- **SessionController** for role session (swap later for real auth)
- **Shared theme + widgets** for coherent UI
- **Named routes** for clear navigation

---

## How to preview (demo credentials)

```bash
cd Frontend
flutter pub get
flutter run
```

| Entry | Credentials (design only) |
|-------|---------------------------|
| Student | `student` / `student` |
| Admin | `admin` / `admin` |
| Guest | no login |

Yellow **Design preview** banners mark screens that are UI-only for now.

---

## Screen map

1. **Welcome** → Login Student · Guest · Admin  
2. **Student Login** → Student Home → Navigation / My Attendance QR / Parking / Profile  
3. **Guest Home** → Navigation only (Attendance & Parking locked)  
4. **Admin Login** → Admin Home → Navigation / Attendance / Parking modules  

---

## Secrets (important)

- **Do not commit** Cloudflare API keys or account passwords.
- Copy `lib/core/config/secrets.example.dart` → `secrets.dart` (gitignored) when starting Step 2.
- Navigation Worker URL is in `AppConfig.navigationWorkerUrl` (non-secret).
- **Rotate** any password or API key that was shared in chat — treat it as exposed.

---

## Next steps (Step 2+)

1. Wire **Navigation** repository to Cloudflare Worker (API key from `secrets.dart`).
2. Keep mock **Users** until teammates finish Cloudflare users table.
3. Keep mock **Attendance** until attendance DB + classroom scanner contract are ready.
4. Add Firebase for **Parking** IoT stream.
5. Replace mock auth with real Cloudflare user login.

---

## Attendance model (confirmed)

```
Student Flutter app  →  shows rotating personal QR
Classroom device app →  camera scans student QR
Cloudflare attendance DB → stores present / absent records
Admin Flutter view →  reads attendance module (later)
```
