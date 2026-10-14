/// Author / Project Supervisor : Omar Terro
/// GitHub                      : https://github.com/IOTERRO
/// Website                     : https://omarterro.fr
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni - Smart University CityU

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import 'attendance.dart';
import 'parking.dart';
import 'navigation.dart';

// ==================== APP THEME ====================

const Color serviceNavy = Color(0xFF15365A);
const Color serviceBlue = Color(0xFF2457A7);
const Color serviceBackground = Color(0xFFF4F7FB);
const Color serviceText = Color(0xFF1D2939);
const Color serviceSecondaryText = Color(0xFF667085);

// ==================== API SERVICE ====================

class ApiService {
  static String baseUrl =
      'https://smart-university-api.khaledothman750.workers.dev';

  static String? token;

  static Map<String, String> getHeaders() {
    return {
      'Content-Type': 'application/json',
      if (token != null && token!.isNotEmpty)
        'Authorization': 'Bearer $token',
    };
  }

  static Future<http.Response> get(String endpoint) async {
    return http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: getHeaders(),
    );
  }

  static Future<http.Response> post(
    String endpoint,
    dynamic body,
  ) async {
    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: getHeaders(),
      body: jsonEncode(body),
    );
  }
}

// ==================== CAMPUS SERVICES SCREEN ====================

class ServicesScreen extends StatelessWidget {
  const ServicesScreen({super.key});

  bool get _isLoggedIn =>
      ApiService.token != null && ApiService.token!.isNotEmpty;

  void _openService(
    BuildContext context,
    Widget page,
    String serviceName,
  ) {
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text('Please log in to access $serviceName.'),
            backgroundColor: serviceNavy,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = _isLoggedIn;

    return Scaffold(
      backgroundColor: serviceBackground,
      appBar: AppBar(
        backgroundColor: serviceNavy,
        foregroundColor: Colors.white,
        elevation: 0,
        automaticallyImplyLeading: false,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Campus Services',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 3),
            Text(
              'City University · Abi Samra Campus',
              style: TextStyle(
                fontSize: 11,
                color: Colors.white70,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 7,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.18),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: isLoggedIn
                            ? const Color(0xFF5BE0A0)
                            : const Color(0xFFFFC36A),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isLoggedIn ? 'SIGNED IN' : 'GUEST',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 24, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Everything in one place',
                style: TextStyle(
                  color: serviceText,
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Access smart tools designed to make your campus experience easier.',
                style: TextStyle(
                  color: serviceSecondaryText,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 22),

              // Account status panel
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: const Color(0xFFE5EAF1),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: isLoggedIn
                            ? const Color(0xFFE5F7ED)
                            : const Color(0xFFFFF3DF),
                        borderRadius: BorderRadius.circular(13),
                      ),
                      child: Icon(
                        isLoggedIn
                            ? Icons.verified_user_outlined
                            : Icons.lock_outline_rounded,
                        color: isLoggedIn
                            ? const Color(0xFF16804A)
                            : const Color(0xFFB7791F),
                        size: 25,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isLoggedIn
                                ? 'Account authenticated'
                                : 'Guest access',
                            style: const TextStyle(
                              color: serviceText,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isLoggedIn
                                ? 'You can access protected services.'
                                : 'Log in to use attendance, parking and navigation.',
                            style: const TextStyle(
                              color: serviceSecondaryText,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 28),

              const Text(
                'Available Services',
                style: TextStyle(
                  color: serviceText,
                  fontSize: 19,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 5),
              const Text(
                'Choose a service to get started.',
                style: TextStyle(
                  color: serviceSecondaryText,
                  fontSize: 13,
                ),
              ),

              const SizedBox(height: 16),

              _ServiceCard(
                title: 'QR Attendance',
                subtitle: 'Scan your QR code to manage attendance.',
                icon: Icons.qr_code_scanner_rounded,
                accentColor: const Color(0xFF2457A7),
                tag: 'ATTENDANCE',
                onTap: () => _openService(
                  context,
                  AttendanceScreen(),
                  'QR Attendance',
                ),
              ),

              const SizedBox(height: 14),

              _ServiceCard(
                title: 'Smart Parking',
                subtitle: 'Access campus parking features.',
                icon: Icons.local_parking_rounded,
                accentColor: const Color(0xFFD94B50),
                tag: 'PARKING',
                onTap: () => _openService(
                  context,
                  ParkingScreen(),
                  'Smart Parking',
                ),
              ),

              const SizedBox(height: 14),

              _ServiceCard(
                title: 'Campus Navigation',
                subtitle: 'Find your way around the campus.',
                icon: Icons.explore_outlined,
                accentColor: const Color(0xFF16856B),
                tag: 'NAVIGATION',
                onTap: () => _openService(
                  context,
                  NavigationScreen(),
                  'Campus Navigation',
                ),
              ),

              const SizedBox(height: 24),

              Center(
                child: Text(
                  'SMART UNIVERSITY  •  CITY UNIVERSITY',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.blueGrey.shade400,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ==================== SERVICE CARD ====================

class _ServiceCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color accentColor;
  final String tag;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.accentColor,
    required this.tag,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE5EAF1),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: accentColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: accentColor,
                  size: 29,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      tag,
                      style: TextStyle(
                        color: accentColor,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      title,
                      style: const TextStyle(
                        color: serviceText,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: serviceSecondaryText,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 16,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
