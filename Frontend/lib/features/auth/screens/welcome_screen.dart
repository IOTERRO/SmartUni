import 'package:flutter/material.dart';

import '../../../app/router/app_routes.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/config/app_config.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/widgets/design_mode_banner.dart';

/// Landing screen matching the whiteboard entry points:
/// Student login · Guest · Admin shortcut.
class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.navy,
      body: Stack(
        children: [
          const Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color(0xFF06152C),
                    Color(0xFF0C2850),
                    Color(0xFF10213E),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            top: -160,
            right: -90,
            child: _Glow(size: 380, color: AppColors.blue.withOpacity(0.14)),
          ),
          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final wide = constraints.maxWidth >= 720;
                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: wide ? 36 : 20,
                    vertical: 18,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 480),
                      child: Column(
                        children: [
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: () => Navigator.pushNamed(
                                context,
                                AppRoutes.adminLogin,
                              ),
                              icon: const Icon(Icons.admin_panel_settings_outlined, size: 18),
                              label: const Text('Admin'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(color: Colors.white.withOpacity(0.24)),
                                backgroundColor: Colors.white.withOpacity(0.05),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          _Branding(wide: wide),
                          const SizedBox(height: 28),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(24),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.2),
                                  blurRadius: 40,
                                  offset: const Offset(0, 18),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const DesignModeBanner(),
                                const Text(
                                  'Welcome',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Color(0xFF122440),
                                    fontSize: 26,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Choose how you want to enter the campus app.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 13,
                                    height: 1.5,
                                  ),
                                ),
                                const SizedBox(height: 26),
                                ElevatedButton.icon(
                                  onPressed: () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.studentLogin,
                                  ),
                                  icon: const Icon(Icons.school_outlined),
                                  label: const Text('Login Student'),
                                ),
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    SessionController.instance.continueAsGuest();
                                    Navigator.pushNamedAndRemoveUntil(
                                      context,
                                      AppRoutes.guestHome,
                                      (_) => false,
                                    );
                                  },
                                  icon: const Icon(Icons.person_pin_circle_outlined),
                                  label: const Text('Continue as Guest'),
                                ),
                                const SizedBox(height: 18),
                                Text(
                                  'Guest → Navigation only\n'
                                  'Student → Navigation · Attendance · Parking\n'
                                  'Admin → Module management views',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: AppColors.textSecondary.withOpacity(0.95),
                                    fontSize: 11,
                                    height: 1.55,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 22),
                          Text(
                            '${AppConfig.appName.toUpperCase()}  •  2027',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.4),
                              fontSize: 10,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _Branding extends StatelessWidget {
  final bool wide;

  const _Branding({required this.wide});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: wide ? 84 : 74,
          height: wide ? 84 : 74,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(22),
          ),
          child: Image.asset(
            'assets/images/cityu_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) => const Icon(
              Icons.account_balance_rounded,
              size: 42,
              color: AppColors.blue,
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          AppConfig.appName.toUpperCase(),
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: wide ? 36 : 30,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          AppConfig.campusName,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFFD2E1F4).withOpacity(0.9),
            fontSize: 13,
          ),
        ),
      ],
    );
  }
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;

  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }
}
