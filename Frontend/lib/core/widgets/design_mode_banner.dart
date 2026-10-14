/// Author / Project Supervisor : Omar Terro
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni — Smart University CityU
import 'package:flutter/material.dart';

import '../config/app_config.dart';
import '../constants/app_constants.dart';
import '../../app/theme/app_colors.dart';

class DesignModeBanner extends StatelessWidget {
  const DesignModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    if (!AppConfig.designMode) return const SizedBox.shrink();

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF7E8),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFF3D9A4)),
      ),
      child: const Row(
        children: [
          Icon(Icons.design_services_outlined, size: 18, color: AppColors.warning),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              AppConstants.designModeHint,
              style: TextStyle(
                color: Color(0xFF7A5A1E),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
