/// Author / Project Supervisor : Omar Terro
/// GitHub                      : https://github.com/IOTERRO
/// Website                     : https://omarterro.fr
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni - Smart University CityU
import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/config/app_config.dart';
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
            const SectionHeader(
              title: 'Parking IoT module',
              subtitle:
                  'ESP32 ultrasonic node (`iot/parking_node`) → Firebase → Flutter.',
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Live architecture',
                    style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '• 3× HC-SR04 on ESP32 (P1 Front, P2 Left, P3 Right)\n'
                    '• Push occupancy to Firebase RTDB\n'
                    '• Path: ${AppConfig.firebaseParkingPath}\n'
                    '• Attendance stays on Cloudflare (app QR) — not IoT',
                    style: const TextStyle(
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
              label: const Text('Open live parking'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.parkingAccent,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
