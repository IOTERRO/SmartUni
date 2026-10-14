<!--
  Author / Project Supervisor : Omar Terro
  GitHub                      : https://github.com/IOTERRO
  Website                     : https://omarterro.fr
  Student (FYP)               : Khaled Othman
  Date                        : 14 October 2026
  Project                     : SmartUni - Smart University CityU
-->
# Smart University (CityU) — Flutter app

Step 1: **professional structure + design screens** (mock data / no live backends yet).

## Run

```bash
flutter pub get
flutter run
```

## Demo logins (design only)

| Role | Credentials |
|------|-------------|
| Student | `student` / `student` |
| Admin | `admin` / `admin` |
| Guest | Continue as Guest (no password) |

## Docs

- `docs/02_STEP1_DESIGN_ARCHITECTURE.md` — structure & screen map
- `docs/01_FRONTEND_CODE_UNDERSTANDING.md` — old prototype notes

## Secrets

Copy `lib/core/config/secrets.example.dart` → `secrets.dart` before Step 2 API wiring. Never commit real keys.
