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

/// Guest role: Navigation only (whiteboard).
class GuestHomeScreen extends StatelessWidget {
  const GuestHomeScreen({super.key});

  void _exit(BuildContext context) {
    SessionController.instance.clear();
    Navigator.pushNamedAndRemoveUntil(context, AppRoutes.welcome, (_) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Guest Access'),
            SizedBox(height: 2),
            Text(
              'Navigation only',
              style: TextStyle(fontSize: 11, color: Colors.white70, fontWeight: FontWeight.w400),
            ),
          ],
        ),
        leading: IconButton(
          tooltip: 'Back to welcome',
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => _exit(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(18, 20, 18, 28),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const DesignModeBanner(),
              const CampusHeroCard(
                title: 'Welcome, Guest',
                subtitle: 'Explore campus locations without signing in.',
                icon: Icons.explore_outlined,
                gradient: [Color(0xFF0F3D3A), AppColors.guestAccent],
              ),
              const SizedBox(height: 28),
              const SectionHeader(
                title: 'Available for guests',
                subtitle: 'Attendance and Parking require a student login.',
              ),
              const SizedBox(height: 14),
              ServiceCard(
                title: 'Campus Navigation',
                subtitle: 'Find buildings, labs, and offices.',
                icon: Icons.map_outlined,
                accent: AppColors.navigationAccent,
                tag: 'PUBLIC',
                onTap: () => Navigator.pushNamed(context, AppRoutes.navigation),
              ),
              const SizedBox(height: 12),
              const _LockedHint(
                title: 'Attendance',
                reason: 'Students only — personal QR check-in',
              ),
              const SizedBox(height: 10),
              const _LockedHint(
                title: 'Parking',
                reason: 'Students only — live IoT slot status',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LockedHint extends StatelessWidget {
  final String title;
  final String reason;

  const _LockedHint({required this.title, required this.reason});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          const Icon(Icons.lock_outline_rounded, color: AppColors.textSecondary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  reason,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
