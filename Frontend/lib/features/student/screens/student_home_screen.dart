/// Author / Project Supervisor : Omar Terro
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni — Smart University CityU
import 'package:flutter/material.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/widgets/campus_hero_card.dart';
import '../../../core/widgets/design_mode_banner.dart';
import '../../../core/widgets/section_header.dart';
import '../../../core/widgets/service_card.dart';

/// Student role: Navigation · Attendance · Parking.
class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = SessionController.instance.user;

    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Student Home'),
            SizedBox(height: 2),
            Text(
              'Campus services',
              style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Profile',
            onPressed: () => Navigator.pushNamed(context, AppRoutes.studentProfile),
            icon: const Icon(Icons.account_circle_rounded, size: 28),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DesignModeBanner(),
              CampusHeroCard(
                title: 'Hello, ${user?.displayName ?? 'Student'}',
                subtitle: 'Navigation, your attendance QR, and live parking.',
              ),
              const SizedBox(height: 28),
              const SectionHeader(
                title: 'Your services',
                subtitle: 'Everything you need for campus life.',
              ),
              const SizedBox(height: 14),
              ServiceCard(
                title: 'Campus Navigation',
                subtitle: 'Find buildings and plan a route.',
                icon: Icons.map_outlined,
                accent: AppColors.navigationAccent,
                tag: 'NAVIGATION',
                onTap: () => Navigator.pushNamed(context, AppRoutes.navigation),
              ),
              const SizedBox(height: 12),
              ServiceCard(
                title: 'My Attendance QR',
                subtitle: 'Show your rotating QR to the classroom scanner.',
                icon: Icons.qr_code_2_rounded,
                accent: AppColors.attendanceAccent,
                tag: 'ATTENDANCE',
                onTap: () => Navigator.pushNamed(context, AppRoutes.attendanceQr),
              ),
              const SizedBox(height: 12),
              ServiceCard(
                title: 'Smart Parking',
                subtitle: 'See available slots from IoT sensors.',
                icon: Icons.local_parking_rounded,
                accent: AppColors.parkingAccent,
                tag: 'PARKING',
                onTap: () => Navigator.pushNamed(context, AppRoutes.parking),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
