<!--
  Author / Project Supervisor : Omar Terro
  GitHub                      : https://github.com/IOTERRO
  Website                     : https://omarterro.fr
  Student (FYP)               : Khaled Othman
  Project                     : SmartUni - Smart University CityU
-->
# Smart University (CityU) — Flutter app (`Frontend/`)

Main campus app: Guest / Student / Admin.  
Live backends: Cloudflare Workers (auth, navigation, attendance) + Firebase parking.

## Run

```powershell
# Copy lib/core/config/secrets.example.dart → secrets.dart and fill keys
flutter pub get
flutter run -d chrome --web-port=8090
```

## Demo logins (D1 seed)

| Role | Credentials |
|------|-------------|
| Student | `student` / `student` |
| Admin | `admin` / `admin` |
| Guest | Continue as Guest (no password) |

## Docs

- [`docs/OVERVIEW.md`](../docs/OVERVIEW.md) — simple product overview  
- [`docs/ARCHITECTURE_DETAILED.md`](../docs/ARCHITECTURE_DETAILED.md) — full architecture & code guide  

Classroom QR reader is a **separate** app: [`../ClassroomScanner/`](../ClassroomScanner/).

## Secrets

Copy `lib/core/config/secrets.example.dart` → `secrets.dart`. Never commit real keys.
