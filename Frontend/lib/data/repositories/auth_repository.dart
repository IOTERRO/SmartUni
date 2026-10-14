import '../../core/constants/app_constants.dart';
import '../../core/enums/user_role.dart';
import '../../core/models/app_user.dart';

/// Contract for authentication.
/// Live: [CloudflareAuthRepository]. Design: [MockAuthRepository].
abstract class AuthRepository {
  Future<AppUser> loginStudent({
    required String universityId,
    required String password,
  });

  Future<AppUser> loginAdmin({
    required String username,
    required String password,
  });
}

class MockAuthRepository implements AuthRepository {
  @override
  Future<AppUser> loginStudent({
    required String universityId,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    if (universityId.trim().isEmpty || password.isEmpty) {
      throw AuthException('Enter your university ID and password.');
    }

    // Design mode: accept demo credentials or any non-empty pair.
    final isDemo = universityId.trim().toLowerCase() ==
            AppConstants.demoStudentId &&
        password == AppConstants.demoStudentPassword;

    if (!isDemo && universityId.trim().length < 3) {
      throw AuthException('Invalid university ID (design preview).');
    }

    return AppUser(
      id: 'STU-${universityId.trim().toUpperCase()}',
      displayName: isDemo ? 'Khaled Othman' : 'Student ${universityId.trim()}',
      identifier: universityId.trim(),
      role: UserRole.student,
      faculty: 'Engineering Faculty',
      email: '${universityId.trim()}@st.cityu.edu.lb',
    );
  }

  @override
  Future<AppUser> loginAdmin({
    required String username,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 450));

    if (username.trim().isEmpty || password.isEmpty) {
      throw AuthException('Enter username and password.');
    }

    final ok = username.trim().toLowerCase() == AppConstants.demoAdminUsername &&
        password == AppConstants.demoAdminPassword;

    if (!ok) {
      throw AuthException('Incorrect administrator credentials (use admin / admin).');
    }

    return const AppUser(
      id: 'ADM-001',
      displayName: 'Campus Administrator',
      identifier: 'admin',
      role: UserRole.admin,
      faculty: 'Administration',
      email: 'admin@cityu.edu.lb',
    );
  }
}

class AuthException implements Exception {
  final String message;
  AuthException(this.message);

  @override
  String toString() => message;
}
