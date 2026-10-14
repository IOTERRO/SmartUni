import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/design_mode_banner.dart';
import '../../../core/widgets/section_header.dart';
import '../../parking/screens/parking_screen.dart';

class AdminParkingScreen extends StatelessWidget {
  const AdminParkingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Parking')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            const DesignModeBanner(),
            const SectionHeader(
              title: 'Parking IoT module',
              subtitle: 'Sensors push occupancy to Firebase; admin monitors from here.',
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Architecture choice',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Ultrasonic / ESP32 sensors on parking spots\n'
                    '• Push live state to Firebase Realtime Database\n'
                    '• Flutter reads Firebase for student + admin views\n'
                    '• Cloudflare remains for navigation / users / attendance',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.5,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ParkingScreen()),
                );
              },
              icon: const Icon(Icons.local_parking_rounded),
              label: const Text('Open parking preview'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.parkingAccent,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Firebase project binding comes in a later step.'),
                  ),
                );
              },
              icon: const Icon(Icons.link_rounded),
              label: const Text('Connect Firebase (soon)'),
            ),
          ],
        ),
      ),
    );
  }
}
