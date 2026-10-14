import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "https://smart-university-api.khaledothman750.workers.dev";

  static Future<Map<String, String>> _getHeaders({bool withAuth = true}) async {
    Map<String, String> headers = {"Content-Type": "application/json"};
    if (withAuth) {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      if (token != null) {
        headers["Authorization"] = "Bearer $token";
      }
    }
    return headers;
  }

  // ========== AUTH ==========
  static Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      final data = jsonDecode(res.body);
      if (res.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        await prefs.setString('role', data['user']['role']);
        await prefs.setString('name', data['user']['full_name']);
        await prefs.setInt('user_id', data['user']['id']);
      }
      return data;
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> register(String name, String email, String password, String role) async {
    try {
      final res = await http.post(
        Uri.parse("$baseUrl/api/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "full_name": name,
          "email": email,
          "password": password,
          "role": role
        }),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {"success": false, "error": e.toString()};
    }
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
  }

  // ========== MAP & NAVIGATION - WORKS FOR GUEST / STUDENT / INSTRUCTOR ==========
  static Future<Map<String, dynamic>> getLocations() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse("$baseUrl/api/locations"), headers: headers);
      return jsonDecode(res.body);
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  static Future<Map<String, dynamic>> getNavigation(String from, String to) async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse("$baseUrl/api/navigation?from=$from&to=$to"), headers: headers);
      return jsonDecode(res.body);
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  static Future<List<dynamic>> searchLocations(String query) async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse("$baseUrl/api/locations/search?q=$query"), headers: headers);
      final data = jsonDecode(res.body);
      return data is List ? data : [];
    } catch (e) {
      return [];
    }
  }

  static Future<Map<String, dynamic>> getParking() async {
    try {
      final headers = await _getHeaders(withAuth: false);
      final res = await http.get(Uri.parse("$baseUrl/api/parking"), headers: headers);
      return jsonDecode(res.body);
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  // ========== ATTENDANCE ==========
  static Future<Map<String, dynamic>> scanAttendance(String qrToken) async {
    try {
      final headers = await _getHeaders();
      final res = await http.post(
        Uri.parse("$baseUrl/api/attendance/scan"),
        headers: headers,
        body: jsonEncode({"qr_token": qrToken}),
      );
      return jsonDecode(res.body);
    } catch (e) {
      return {"error": e.toString()};
    }
  }

  // ========== COURSES ==========
  static Future<List<dynamic>> getCourses() async {
    try {
      final headers = await _getHeaders();
      final res = await http.get(Uri.parse("$baseUrl/api/courses"), headers: headers);
      final data = jsonDecode(res.body);
      return data is List ? data : [];
    } catch (e) {
      return [];
    }
  }

  // ========== HELPERS ==========
  static Future<String?> getRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('role');
  }

  static Future<bool> isGuest() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') == null;
  }
}