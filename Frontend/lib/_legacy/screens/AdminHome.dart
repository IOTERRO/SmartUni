/// Author / Project Supervisor : Omar Terro
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni — Smart University CityU

import 'package:flutter/material.dart';

import 'login.dart';
import 'profile.dart';
import 'services.dart';
import 'attendance.dart';
import 'parking.dart';
import 'navigation.dart';

const Color navyBlue = Color(0xFF15365A);
const Color primaryBlue = Color(0xFF2457A7);
const Color backgroundColor = Color(0xFFF4F7FB);
const Color textColor = Color(0xFF1D2939);
const Color secondaryTextColor = Color(0xFF667085);

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  void _backToLogin(BuildContext context) {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginScreen(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return HomeDashboardView(
      onBackToLogin: () => _backToLogin(context),
    );
  }
}

class HomeDashboardView extends StatelessWidget {
  final VoidCallback onBackToLogin;

  const HomeDashboardView({
    super.key,
    required this.onBackToLogin,
  });

  void _openService(
    BuildContext context,
    String serviceName,
    Widget screen,
  ) {
    if (ApiService.token == null ||
        ApiService.token!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please log in to access $serviceName.'),
          behavior: SnackBarBehavior.floating,
          backgroundColor: navyBlue,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => screen,
      ),
    );
  }

  void _openProfile(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const ProfileScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,

      appBar: AppBar(
        backgroundColor: navyBlue,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          tooltip: 'Back to Login',
          icon: const Icon(
            Icons.arrow_back_ios_new_rounded,
            size: 19,
          ),
          onPressed: onBackToLogin,
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Smart University',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 2),
            Text(
              'City University · Abi Samra Campus',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w400,
                color: Colors.white70,
              ),
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: IconButton(
              tooltip: 'Profile',
              onPressed: () => _openProfile(context),
              icon: const Icon(
                Icons.account_circle_rounded,
                size: 29,
              ),
            ),
          ),
        ],
      ),

      body: SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 22, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Welcome to your campus',
                style: TextStyle(
                  color: textColor,
                  fontSize: 25,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Everything you need for a smarter university experience.',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // University welcome banner
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [navyBlue, primaryBlue],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: primaryBlue.withOpacity(0.20),
                      blurRadius: 16,
                      offset: const Offset(0, 7),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'YOUR CAMPUS',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                            ),
                          ),
                          SizedBox(height: 15),
                          Text(
                            'City University',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          SizedBox(height: 7),
                          Text(
                            'Abi Samra Campus Services',
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Container(
                      width: 66,
                      height: 66,
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.13),
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: Colors.white,
                        size: 38,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              const Text(
                'Campus Services',
                style: TextStyle(
                  color: textColor,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 7),
              const Text(
                'Access your essential campus tools.',
                style: TextStyle(
                  color: secondaryTextColor,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 16),

              // 1. Create QR-Code
              _ServiceCard(
                icon: Icons.qr_code_2_rounded,
                title: 'Create QR-Code',
                subtitle: 'Generate a QR code for attendance',
                iconColor: primaryBlue,
                onTap: () => _openService(
                  context,
                  'Create QR-Code',
                  AttendanceScreen(),
                ),
              ),
              const SizedBox(height: 12),

              // 2. View Attendance Sheet
              _ServiceCard(
                icon: Icons.fact_check_outlined,
                title: 'View Attendance Sheet',
                subtitle: 'View and manage attendance records',
                iconColor: const Color(0xFF0D9488),
                onTap: () => _openService(
                  context,
                  'View Attendance Sheet',
                  AttendanceScreen(),
                ),
              ),
              const SizedBox(height: 12),

              // 3. Parking
              _ServiceCard(
                icon: Icons.local_parking_rounded,
                title: 'Parking',
                subtitle: 'Access campus parking services',
                iconColor: const Color(0xFFB7791F),
                onTap: () => _openService(
                  context,
                  'Parking',
                  ParkingScreen(),
                ),
              ),
              const SizedBox(height: 12),

              // 4. Campus Navigation
              _ServiceCard(
                icon: Icons.map_outlined,
                title: 'Campus Navigation',
                subtitle: 'Find your way around campus',
                iconColor: const Color(0xFF7C3AED),
                onTap: () => _openService(
                  context,
                  'Campus Navigation',
                  NavigationScreen(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color iconColor;
  final VoidCallback onTap;

  const _ServiceCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: const Color(0xFFE7ECF3),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(0.10),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: textColor,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: secondaryTextColor,
                        fontSize: 12,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                color: secondaryTextColor,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
