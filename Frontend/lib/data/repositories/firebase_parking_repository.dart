/// Author / Project Supervisor : Omar Terro
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni — Smart University CityU
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';
import '../../core/config/secrets.dart';
import '../../core/models/parking_slot.dart';
import '../remote/worker_api_client.dart';
import 'parking_repository.dart';

/// Reads parking bay status from Firebase RTDB (written by ESP32 IoT node).
class FirebaseParkingRepository implements ParkingRepository {
  FirebaseParkingRepository({http.Client? httpClient})
      : _http = httpClient ?? http.Client();

  final http.Client _http;
  String? _idToken;
  DateTime? _tokenExpiresAt;

  @override
  Future<ParkingSummary> fetchSummary() async {
    if (Secrets.firebaseApiKey.contains('PASTE_')) {
      throw ApiException(
        'Missing Firebase secrets. Copy secrets.example.dart → secrets.dart.',
      );
    }

    final token = await _ensureIdToken();
    final uri = Uri.parse(
      '${AppConfig.firebaseDatabaseUrl}/${AppConfig.firebaseParkingPath}.json',
    ).replace(queryParameters: {'auth': token});

    final response = await _http.get(uri);
    if (response.statusCode >= 400) {
      throw ApiException(
        'Firebase parking read failed (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (response.body.isEmpty || response.body == 'null') {
      return const ParkingSummary([]);
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw ApiException('Unexpected Firebase parking payload.');
    }

    final slots = <ParkingSlot>[];
    decoded.forEach((key, value) {
      if (value is! Map) return;
      slots.add(
        ParkingSlot.fromFirebaseJson(
          key.toString(),
          Map<String, dynamic>.from(value),
        ),
      );
    });

    slots.sort((a, b) => a.id.compareTo(b.id));
    return ParkingSummary(slots);
  }

  Future<String> _ensureIdToken() async {
    final now = DateTime.now();
    if (_idToken != null &&
        _tokenExpiresAt != null &&
        now.isBefore(_tokenExpiresAt!)) {
      return _idToken!;
    }

    final uri = Uri.parse(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword',
    ).replace(queryParameters: {'key': Secrets.firebaseApiKey});

    final response = await _http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': Secrets.firebaseAuthEmail,
        'password': Secrets.firebaseAuthPassword,
        'returnSecureToken': true,
      }),
    );

    final json = jsonDecode(response.body);
    if (response.statusCode >= 400 || json is! Map) {
      final message = json is Map
          ? (json['error'] is Map
              ? (json['error']['message']?.toString())
              : null)
          : null;
      throw ApiException(
        message?.isNotEmpty == true
            ? 'Firebase auth: $message'
            : 'Firebase sign-in failed (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    final map = Map<String, dynamic>.from(json);
    final token = map['idToken'] as String?;
    final expiresIn = int.tryParse(map['expiresIn']?.toString() ?? '') ?? 3600;
    if (token == null || token.isEmpty) {
      throw ApiException('Firebase sign-in returned no idToken.');
    }

    _idToken = token;
    // Refresh a minute early.
    _tokenExpiresAt = now.add(Duration(seconds: expiresIn - 60));
    return token;
  }
}
