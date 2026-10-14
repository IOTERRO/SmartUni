/// Author / Project Supervisor : Omar Terro
/// GitHub                      : https://github.com/IOTERRO
/// Website                     : https://omarterro.fr
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni - Smart University CityU
/// Copy this file to `secrets.dart` and fill values locally.
/// `secrets.dart` is gitignored — never commit real keys.
///
/// If all three Workers share one Cloudflare secret, paste the same value
/// into each Worker field.
class Secrets {
  Secrets._();

  static const String navigationWorkerApiKey = 'PASTE_KEY_HERE';
  static const String usersWorkerApiKey = 'PASTE_KEY_HERE';
  static const String attendanceWorkerApiKey = 'PASTE_KEY_HERE';

  /// Firebase Web API key (same as ESP `API_KEY` / firebase_info.txt).
  static const String firebaseApiKey = 'PASTE_FIREBASE_WEB_API_KEY';

  /// Email/password user that can read RTDB (same as ESP auth user).
  static const String firebaseAuthEmail = 'PASTE_FIREBASE_AUTH_EMAIL';
  static const String firebaseAuthPassword = 'PASTE_FIREBASE_AUTH_PASSWORD';
}
