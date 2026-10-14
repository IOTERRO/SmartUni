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
