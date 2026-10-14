// Author / Project Supervisor : Omar Terro
// GitHub                      : https://github.com/IOTERRO
// Website                     : https://omarterro.fr
// Student (FYP)               : Khaled Othman
// Date                        : 14 October 2026
// Project                     : SmartUni - Classroom Scanner
class AppConfig {
  AppConfig._();

  static const String appName = 'SmartUni Classroom Scanner';
  static const String campusName = 'City University · Abi Samra Campus';

  static const String usersWorkerUrl =
      'https://users.khaledothman750.workers.dev';

  static const String attendanceWorkerUrl =
      'https://smart-university.khaledothman750.workers.dev';

  /// Sent with each scan so Cloudflare can log the classroom device.
  static const String scannerDeviceId = 'CLASSROOM-SCANNER-01';

  /// Ignore duplicate scans of the same QR text for this duration.
  static const Duration scanCooldown = Duration(seconds: 3);
}
