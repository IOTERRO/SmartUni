/// Non-secret application configuration.
///
/// Secrets (API keys) belong in `secrets.dart` (gitignored).
/// Copy from `secrets.example.dart` when you start Step 2 integrations.
class AppConfig {
  AppConfig._();

  static const String appName = 'Smart University';
  static const String campusName = 'City University · Abi Samra Campus';

  /// Cloudflare Worker for campus Navigation (D1: cityu).
  static const String navigationWorkerUrl =
      'https://navigation.khaledothman750.workers.dev';

  /// Cloudflare Worker for users / login (D1: users).
  static const String usersWorkerUrl =
      'https://users.khaledothman750.workers.dev';

  /// Cloudflare Worker for attendance (D1: smart-university-db).
  static const String attendanceWorkerUrl =
      'https://smart-university.khaledothman750.workers.dev';

  /// Firebase will host live parking IoT sensor state (Step 2+).
  static const bool parkingUsesFirebase = true;

  /// When true, auth + navigation use Cloudflare Workers (not mock data).
  static const bool useCloudflareApis = true;

  /// Step 1 design banner. Off for Step 2 live Cloudflare wiring.
  static const bool designMode = false;

  /// How often the student attendance QR rotates in the UI (design preview).
  static const Duration studentQrRefreshInterval = Duration(seconds: 20);
}
