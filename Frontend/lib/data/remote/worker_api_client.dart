/// Author / Project Supervisor : Omar Terro
/// GitHub                      : https://github.com/IOTERRO
/// Website                     : https://omarterro.fr
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni - Smart University CityU
import 'dart:convert';

import 'package:http/http.dart' as http;

/// Thin HTTP client for Cloudflare Workers (`X-API-Key` + JSON).
class WorkerApiClient {
  WorkerApiClient({
    required this.baseUrl,
    required this.apiKey,
    http.Client? httpClient,
  }) : _http = httpClient ?? http.Client();

  final String baseUrl;
  final String apiKey;
  final http.Client _http;

  Map<String, String> get _headers => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'X-API-Key': apiKey,
      };

  Uri _uri(String path, [Map<String, String>? query]) {
    final normalizedBase = baseUrl.endsWith('/')
        ? baseUrl.substring(0, baseUrl.length - 1)
        : baseUrl;
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.parse('$normalizedBase$normalizedPath').replace(
      queryParameters: query == null || query.isEmpty ? null : query,
    );
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
  }) async {
    final response = await _http.get(_uri(path, query), headers: _headers);
    return _decode(response);
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _http.post(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body ?? {}),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> put(
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final response = await _http.put(
      _uri(path),
      headers: _headers,
      body: jsonEncode(body ?? {}),
    );
    return _decode(response);
  }

  Future<Map<String, dynamic>> delete(String path) async {
    final response = await _http.delete(_uri(path), headers: _headers);
    return _decode(response);
  }

  Map<String, dynamic> _decode(http.Response response) {
    Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) {
        json = decoded;
      } else {
        throw ApiException(
          'Unexpected response from server.',
          statusCode: response.statusCode,
        );
      }
    } on ApiException {
      rethrow;
    } catch (_) {
      throw ApiException(
        'Invalid JSON from server (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    if (response.statusCode >= 400 || json['success'] == false) {
      final message = (json['error'] as String?)?.trim();
      throw ApiException(
        message?.isNotEmpty == true
            ? message!
            : 'Request failed (${response.statusCode}).',
        statusCode: response.statusCode,
      );
    }

    return json;
  }
}

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}
