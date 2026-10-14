/// Application access roles (whiteboard + product model).
enum UserRole {
  guest,
  student,
  admin,
}

extension UserRoleX on UserRole {
  String get label {
    switch (this) {
      case UserRole.guest:
        return 'Guest';
      case UserRole.student:
        return 'Student';
      case UserRole.admin:
        return 'Administrator';
    }
  }

  bool get canAccessAttendance => this == UserRole.student || this == UserRole.admin;

  bool get canAccessParking => this == UserRole.student || this == UserRole.admin;

  bool get canAccessNavigation => true;

  bool get canManageModules => this == UserRole.admin;
}
