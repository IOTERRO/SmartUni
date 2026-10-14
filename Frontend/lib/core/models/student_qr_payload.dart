/// Author / Project Supervisor : Omar Terro
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni — Smart University CityU
/// Payload encoded inside the student's rotating attendance QR.
/// Classroom scanner app will read this in a later step.
class StudentQrPayload {
  final String studentId;
  final String studentName;
  final String token;
  final DateTime issuedAt;
  final DateTime expiresAt;

  const StudentQrPayload({
    required this.studentId,
    required this.studentName,
    required this.token,
    required this.issuedAt,
    required this.expiresAt,
  });

  /// Compact string shown in QR (design format; will match backend later).
  String get encoded =>
      'SMARTUNI|SID:$studentId|TOK:$token|EXP:${expiresAt.millisecondsSinceEpoch}';

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
