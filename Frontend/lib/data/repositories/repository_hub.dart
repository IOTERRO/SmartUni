import 'attendance_repository.dart';
import 'auth_repository.dart';
import 'navigation_repository.dart';
import 'parking_repository.dart';

/// Central place to swap mock → real implementations later.
class RepositoryHub {
  RepositoryHub._({
    required this.auth,
    required this.navigation,
    required this.parking,
    required this.attendance,
  });

  final AuthRepository auth;
  final NavigationRepository navigation;
  final ParkingRepository parking;
  final AttendanceRepository attendance;

  static final RepositoryHub instance = RepositoryHub._(
    auth: MockAuthRepository(),
    navigation: MockNavigationRepository(),
    parking: MockParkingRepository(),
    attendance: MockAttendanceRepository(),
  );
}
