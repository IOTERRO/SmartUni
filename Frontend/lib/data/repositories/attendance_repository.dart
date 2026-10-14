/// Author / Project Supervisor : Omar Terro
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni — Smart University CityU
import 'dart:math';

import '../../core/config/app_config.dart';
import '../../core/config/secrets.dart';
import '../../core/models/app_user.dart';
import '../../core/models/student_qr_payload.dart';
import '../remote/worker_api_client.dart';

/// Attendance data access.
/// QR is generated on-device; sessions/records come from the Attendance Worker.
abstract class AttendanceRepository {
  StudentQrPayload generateStudentQr(AppUser student);

  Future<List<Map<String, dynamic>>> fetchSessions({String? courseId});

  Future<List<Map<String, dynamic>>> fetchRecords({required String sessionId});
}

class MockAttendanceRepository implements AttendanceRepository {
  final _random = Random();

  @override
  StudentQrPayload generateStudentQr(AppUser student) {
    final now = DateTime.now();
    final token = List.generate(12, (_) => _random.nextInt(16).toRadixString(16))
        .join()
        .toUpperCase();

    // Prefer university username for SID so scans match D1 student_id values.
    final sid = student.identifier.trim().isNotEmpty
        ? student.identifier.trim()
        : student.id;

    return StudentQrPayload(
      studentId: sid,
      studentName: student.displayName,
      token: token,
      issuedAt: now,
      expiresAt: now.add(AppConfig.studentQrRefreshInterval),
    );
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSessions({String? courseId}) async {
    return const [];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRecords({
    required String sessionId,
  }) async {
    return const [];
  }
}

/// Live attendance sessions/records + local rotating QR.
class CloudflareAttendanceRepository implements AttendanceRepository {
  CloudflareAttendanceRepository({
    WorkerApiClient? client,
    MockAttendanceRepository? localQr,
  })  : _client = client ??
            WorkerApiClient(
              baseUrl: AppConfig.attendanceWorkerUrl,
              apiKey: Secrets.attendanceWorkerApiKey,
            ),
        _localQr = localQr ?? MockAttendanceRepository();

  final WorkerApiClient _client;
  final MockAttendanceRepository _localQr;

  @override
  StudentQrPayload generateStudentQr(AppUser student) =>
      _localQr.generateStudentQr(student);

  @override
  Future<List<Map<String, dynamic>>> fetchSessions({String? courseId}) async {
    final query = <String, String>{};
    if (courseId != null && courseId.trim().isNotEmpty) {
      query['course_id'] = courseId.trim();
    }
    final json = await _client.get(
      '/api/attendance/sessions',
      query: query.isEmpty ? null : query,
    );
    return _asMapList(json['data']);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchRecords({
    required String sessionId,
  }) async {
    final json = await _client.get(
      '/api/attendance/records',
      query: {'session_id': sessionId},
    );
    return _asMapList(json['data']);
  }

  List<Map<String, dynamic>> _asMapList(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }
}
