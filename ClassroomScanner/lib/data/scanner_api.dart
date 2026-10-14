// Author / Project Supervisor : Omar Terro
// GitHub                      : https://github.com/IOTERRO
// Website                     : https://omarterro.fr
// Student (FYP)               : Khaled Othman
// Date                        : 14 October 2026
// Project                     : SmartUni - Classroom Scanner
import '../core/config/app_config.dart';
import '../core/config/secrets.dart';
import 'worker_api_client.dart';

class ScannerUser {
  final String id;
  final String username;
  final String displayName;
  final String role;

  const ScannerUser({
    required this.id,
    required this.username,
    required this.displayName,
    required this.role,
  });

  factory ScannerUser.fromJson(Map<String, dynamic> json) {
    final fullName = (json['full_name'] as String?)?.trim();
    final username = (json['username'] as String? ?? '').trim();
    return ScannerUser(
      id: json['id'].toString(),
      username: username,
      displayName:
          (fullName != null && fullName.isNotEmpty) ? fullName : username,
      role: (json['role'] as String? ?? '').toLowerCase(),
    );
  }

  bool get isAdmin => role == 'admin';
}

class AttendanceSession {
  final String id;
  final String courseId;
  final String sessionDate;
  final String startTime;
  final String? room;
  final bool isActive;

  const AttendanceSession({
    required this.id,
    required this.courseId,
    required this.sessionDate,
    required this.startTime,
    this.room,
    required this.isActive,
  });

  factory AttendanceSession.fromJson(Map<String, dynamic> json) {
    return AttendanceSession(
      id: json['id']?.toString() ?? '',
      courseId: json['course_id']?.toString() ?? '',
      sessionDate: json['session_date']?.toString() ?? '',
      startTime: json['start_time']?.toString() ?? '',
      room: json['room']?.toString(),
      isActive: json['is_active'] == null || NumberLike.isTruthy(json['is_active']),
    );
  }

  String get label =>
      '$courseId · $sessionDate $startTime${room != null && room!.isNotEmpty ? ' · $room' : ''}';
}

class ScanResult {
  final bool success;
  final String message;
  final String? studentId;
  final String? studentName;
  final String? status;

  const ScanResult({
    required this.success,
    required this.message,
    this.studentId,
    this.studentName,
    this.status,
  });
}

class NumberLike {
  static bool isTruthy(Object? v) {
    if (v is bool) return v;
    if (v is num) return v != 0;
    final s = v?.toString().toLowerCase();
    return s == '1' || s == 'true';
  }
}

// Users login + attendance sessions/scan against Cloudflare Workers.
class ScannerApi {
  ScannerApi({
    WorkerApiClient? usersClient,
    WorkerApiClient? attendanceClient,
  })  : _users = usersClient ??
            WorkerApiClient(
              baseUrl: AppConfig.usersWorkerUrl,
              apiKey: Secrets.usersWorkerApiKey,
            ),
        _attendance = attendanceClient ??
            WorkerApiClient(
              baseUrl: AppConfig.attendanceWorkerUrl,
              apiKey: Secrets.attendanceWorkerApiKey,
            );

  final WorkerApiClient _users;
  final WorkerApiClient _attendance;

  Future<ScannerUser> loginInstructor({
    required String username,
    required String password,
  }) async {
    final id = username.trim();
    if (id.isEmpty || password.isEmpty) {
      throw ApiException('Enter username and password.');
    }
    if (Secrets.usersWorkerApiKey.contains('PASTE_')) {
      throw ApiException(
        'Missing API key. Copy secrets.example.dart → secrets.dart.',
      );
    }

    try {
      final json = await _users.post(
        '/api/login',
        body: {'username': id, 'password': password},
      );
      final userJson = json['user'];
      if (userJson is! Map<String, dynamic>) {
        throw ApiException('Login response was incomplete.');
      }
      final user = ScannerUser.fromJson(userJson);
      if (!user.isAdmin) {
        throw ApiException(
          'Only administrator accounts can open the classroom scanner.',
        );
      }
      return user;
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException('Could not reach the users service.');
    }
  }

  Future<List<AttendanceSession>> fetchSessions() async {
    final json = await _attendance.get('/api/attendance/sessions');
    final raw = json['data'];
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => AttendanceSession.fromJson(Map<String, dynamic>.from(e)))
        .where((s) => s.id.isNotEmpty)
        .toList(growable: false);
  }

  Future<ScanResult> submitScan({
    required String sessionId,
    required String qrRaw,
  }) async {
    try {
      final json = await _attendance.post(
        '/api/attendance/scan',
        body: {
          'session_id': sessionId,
          'qr_raw': qrRaw.trim(),
          'device_id': AppConfig.scannerDeviceId,
        },
      );
      final data = json['data'];
      Map<String, dynamic>? row;
      if (data is Map<String, dynamic>) {
        row = data;
      } else if (data is Map) {
        row = Map<String, dynamic>.from(data);
      }

      final name = row?['student_name']?.toString();
      final sid = row?['student_id']?.toString();
      final status = row?['status']?.toString() ?? 'Present';

      return ScanResult(
        success: true,
        message: name != null && name.isNotEmpty
            ? '$name marked $status'
            : 'Attendance recorded ($status)',
        studentId: sid,
        studentName: name,
        status: status,
      );
    } on ApiException catch (e) {
      return ScanResult(success: false, message: e.message);
    }
  }
}

// Optional local parse of student QR for UI hints.
class StudentQrRaw {
  final String studentId;
  final String token;
  final int? expiresAtMs;

  const StudentQrRaw({
    required this.studentId,
    required this.token,
    this.expiresAtMs,
  });

  static StudentQrRaw? tryParse(String raw) {
    final text = raw.trim();
    if (!text.startsWith('SMARTUNI|')) return null;
    final parts = <String, String>{};
    for (final chunk in text.split('|').skip(1)) {
      final i = chunk.indexOf(':');
      if (i <= 0) continue;
      parts[chunk.substring(0, i)] = chunk.substring(i + 1);
    }
    final sid = parts['SID'];
    final tok = parts['TOK'];
    if (sid == null || tok == null) return null;
    return StudentQrRaw(
      studentId: sid,
      token: tok,
      expiresAtMs: int.tryParse(parts['EXP'] ?? ''),
    );
  }

  bool get isExpired {
    if (expiresAtMs == null) return false;
    return DateTime.now().millisecondsSinceEpoch > expiresAtMs!;
  }
}
