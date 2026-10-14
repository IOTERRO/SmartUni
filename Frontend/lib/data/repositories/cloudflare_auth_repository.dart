/// Author / Project Supervisor : Omar Terro
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni — Smart University CityU
import '../../core/config/app_config.dart';
import '../../core/config/secrets.dart';
import '../../core/enums/user_role.dart';
import '../../core/models/app_user.dart';
import '../remote/worker_api_client.dart';
import 'auth_repository.dart';

/// Login against the Cloudflare Users Worker (`POST /api/login`).
class CloudflareAuthRepository implements AuthRepository {
  CloudflareAuthRepository({WorkerApiClient? client})
      : _client = client ??
            WorkerApiClient(
              baseUrl: AppConfig.usersWorkerUrl,
              apiKey: Secrets.usersWorkerApiKey,
            );

  final WorkerApiClient _client;

  @override
  Future<AppUser> loginStudent({
    required String universityId,
    required String password,
  }) async {
    final user = await _login(
      username: universityId,
      password: password,
    );
    if (user.role != UserRole.student) {
      throw AuthException('This account is not a student account.');
    }
    return user;
  }

  @override
  Future<AppUser> loginAdmin({
    required String username,
    required String password,
  }) async {
    final user = await _login(
      username: username,
      password: password,
    );
    if (user.role != UserRole.admin) {
      throw AuthException('This account is not an administrator account.');
    }
    return user;
  }

  Future<AppUser> _login({
    required String username,
    required String password,
  }) async {
    final id = username.trim();
    if (id.isEmpty || password.isEmpty) {
      throw AuthException('Enter your username and password.');
    }

    if (Secrets.usersWorkerApiKey.contains('PASTE_KEY')) {
      throw AuthException(
        'Missing users API key. Copy secrets.example.dart → secrets.dart.',
      );
    }

    try {
      final json = await _client.post(
        '/api/login',
        body: {
          'username': id,
          'password': password,
        },
      );
      final userJson = json['user'];
      if (userJson is! Map<String, dynamic>) {
        throw AuthException('Login response was incomplete.');
      }
      return AppUser.fromWorkerJson(userJson);
    } on ApiException catch (e) {
      throw AuthException(e.message);
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException('Could not reach the users service. Check your network.');
    }
  }
}
