/// Author / Project Supervisor : Omar Terro
/// GitHub                      : https://github.com/IOTERRO
/// Website                     : https://omarterro.fr
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni - Smart University CityU
import '../enums/user_role.dart';

class AppUser {
  final String id;
  final String displayName;
  final String identifier;
  final UserRole role;
  final String? faculty;
  final String? email;

  const AppUser({
    required this.id,
    required this.displayName,
    required this.identifier,
    required this.role,
    this.faculty,
    this.email,
  });

  factory AppUser.guest() {
    return const AppUser(
      id: 'guest',
      displayName: 'Guest Visitor',
      identifier: 'guest',
      role: UserRole.guest,
    );
  }

  /// Maps Users Worker `publicUser` JSON → app model.
  factory AppUser.fromWorkerJson(Map<String, dynamic> json) {
    final roleRaw = (json['role'] as String? ?? 'student').toLowerCase();
    final role = roleRaw == 'admin' ? UserRole.admin : UserRole.student;
    final username = (json['username'] as String? ?? '').trim();
    final fullName = (json['full_name'] as String?)?.trim();

    return AppUser(
      id: json['id'].toString(),
      displayName:
          (fullName != null && fullName.isNotEmpty) ? fullName : username,
      identifier: username,
      role: role,
      faculty: json['faculty'] as String?,
      email: json['email'] as String?,
    );
  }

  AppUser copyWith({
    String? id,
    String? displayName,
    String? identifier,
    UserRole? role,
    String? faculty,
    String? email,
  }) {
    return AppUser(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      identifier: identifier ?? this.identifier,
      role: role ?? this.role,
      faculty: faculty ?? this.faculty,
      email: email ?? this.email,
    );
  }
}
