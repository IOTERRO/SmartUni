import 'package:flutter/material.dart';

import '../../../app/theme/app_colors.dart';
import '../../../core/widgets/design_mode_banner.dart';
import '../../../core/widgets/section_header.dart';

/// Admin attendance module — design only until Cloudflare table is ready.
class AdminAttendanceScreen extends StatelessWidget {
  const AdminAttendanceScreen({super.key});

  static const _sampleRows = [
    ('STU-202110142', 'Khaled Othman', 'Present', '09:05'),
    ('STU-202110201', 'Sara Haddad', 'Present', '09:06'),
    ('STU-202110318', 'Omar Nasser', 'Absent', '—'),
    ('STU-202110444', 'Maya Farah', 'Present', '09:08'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Admin · Attendance')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(18, 18, 18, 28),
          children: [
            const DesignModeBanner(),
            const SectionHeader(
              title: 'Attendance records',
              subtitle:
                  'Classroom scanner app → Cloudflare attendance DB. Table not ready yet — sample UI only.',
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFEEF4FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFD7E4FF)),
              ),
              child: const Text(
                'Model: each student shows a rotating QR in the Flutter app. '
                'A separate classroom device scans it and posts presence to Cloudflare.',
                style: TextStyle(
                  fontSize: 12,
                  height: 1.45,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              initialValue: 'NET301',
              decoration: const InputDecoration(labelText: 'Course / session'),
              items: const [
                DropdownMenuItem(value: 'NET301', child: Text('NET301 — Smart Networks')),
                DropdownMenuItem(value: 'CSE210', child: Text('CSE210 — Programming II')),
              ],
              onChanged: (_) {},
            ),
            const SizedBox(height: 16),
            ..._sampleRows.map((row) {
              final present = row.$3 == 'Present';
              return Card(
                margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: (present ? AppColors.success : AppColors.danger)
                        .withOpacity(0.12),
                    child: Icon(
                      present ? Icons.check_rounded : Icons.close_rounded,
                      color: present ? AppColors.success : AppColors.danger,
                    ),
                  ),
                  title: Text(row.$2, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(row.$1),
                  trailing: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        row.$3,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          color: present ? AppColors.success : AppColors.danger,
                        ),
                      ),
                      Text(row.$4, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                    ],
                  ),
                ),
              );
            }),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Export / live sync comes after attendance DB is ready.')),
                );
              },
              icon: const Icon(Icons.download_outlined),
              label: const Text('Export sheet (soon)'),
            ),
          ],
        ),
      ),
    );
  }
}
