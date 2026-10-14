/// Copy this file to `secrets.dart` and fill values locally.
/// `secrets.dart` is gitignored — never commit real keys.
///
/// If all three Workers share one Cloudflare secret, paste the same value
/// into each field.
class Secrets {
  Secrets._();

  static const String navigationWorkerApiKey = 'PASTE_KEY_HERE';
  static const String usersWorkerApiKey = 'PASTE_KEY_HERE';
  static const String attendanceWorkerApiKey = 'PASTE_KEY_HERE';
}
