import 'dart:math';

import '../../core/config/app_config.dart';
import '../../core/models/app_user.dart';
import '../../core/models/student_qr_payload.dart';

/// Attendance data access.
/// Step 1: local rotating QR payload only.
/// Later: Cloudflare attendance DB + classroom scanner app.
abstract class AttendanceRepository {
  StudentQrPayload generateStudentQr(AppUser student);
}

class MockAttendanceRepository implements AttendanceRepository {
  final _random = Random();

  @override
  StudentQrPayload generateStudentQr(AppUser student) {
    final now = DateTime.now();
    final token = List.generate(12, (_) => _random.nextInt(16).toRadixString(16))
        .join()
        .toUpperCase();

    return StudentQrPayload(
      studentId: student.id,
      studentName: student.displayName,
      token: token,
      issuedAt: now,
      expiresAt: now.add(AppConfig.studentQrRefreshInterval),
    );
  }
}
