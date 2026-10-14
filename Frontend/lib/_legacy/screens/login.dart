/// Author / Project Supervisor : Omar Terro
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni — Smart University CityU

import 'package:flutter/material.dart';

import 'home.dart';
import 'Guesthome.dart';
import 'Admin.dart';
import '../services/api_services.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController universityIdController =
      TextEditingController();
  final TextEditingController passwordController =
      TextEditingController();

  bool hidePassword = true;
  bool isLoading = false;

  static const Color navy = Color(0xFF071B36);
  static const Color navyLight = Color(0xFF102D53);
  static const Color blue = Color(0xFF2864D7);
  static const Color skyBlue = Color(0xFF73B8FF);
  static const Color pageWhite = Color(0xFFFFFFFF);
  static const Color muted = Color(0xFF77869B);
  static const Color border = Color(0xFFE2E9F2);

  void openHome() {
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const HomeScreen(),
      ),
    );
  }

  void openAdministrator() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminScreen(),
      ),
    );
  }

  void continueAsGuest() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => const GuestHomeScreen(),
      ),
    );
  }

  Future<void> login() async {
    final email = universityIdController.text.trim();
    final password = passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please enter your University ID and password.',
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Existing temporary test-account access.
    if (email == '12345khaled@gmail.com' &&
        password == '123456789') {
      openHome();
      return;
    }

    setState(() => isLoading = true);

    try {
      final data = await ApiService.login(email, password);

      if (!mounted) return;

      if (data['success'] == true && data['token'] != null) {
        final user = data['user'];
        final name = user?['full_name'] ?? 'User';
        final role = user?['role'] ?? 'Student';

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome $name - $role'),
            behavior: SnackBarBehavior.floating,
          ),
        );

        debugPrint('Logged in as: $role');
        openHome();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Login failed.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      debugPrint('Login error: $e');

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Login error: $e'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  InputDecoration fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffixIcon,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: blue, size: 21),
      suffixIcon: suffixIcon,
      filled: true,
      fillColor: const Color(0xFFF7F9FC),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 20,
      ),
      hintStyle: const TextStyle(
        color: Color(0xFF99A5B5),
        fontSize: 13,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: const BorderSide(
          color: blue,
          width: 1.7,
        ),
      ),
    );
  }

  @override
  void dispose() {
    universityIdController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: navy,
      body: Stack(
        children: [
          // Deep blue background.
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

          // Atmospheric blue lighting.
          Positioned(
            top: -170,
            right: -100,
            child: _GlowCircle(
              size: 420,
              color: const Color(0xFF2675E8).withOpacity(0.13),
            ),
          ),
          Positioned(
            bottom: -210,
            left: -120,
            child: _GlowCircle(
              size: 440,
              color: const Color(0xFF49B7FF).withOpacity(0.09),
            ),
          ),

          SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isDesktop = constraints.maxWidth >= 760;

                return SingleChildScrollView(
                  padding: EdgeInsets.symmetric(
                    horizontal: isDesktop ? 36 : 20,
                    vertical: isDesktop ? 22 : 14,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(
                        maxWidth: 700,
                      ),
                      child: Column(
                        children: [
                          // Top navigation.
                          Align(
                            alignment: Alignment.centerRight,
                            child: OutlinedButton.icon(
                              onPressed: openAdministrator,
                              icon: const Icon(
                                Icons.admin_panel_settings_outlined,
                                size: 18,
                              ),
                              label: const Text('Administrator'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: Colors.white,
                                side: BorderSide(
                                  color: Colors.white.withOpacity(0.22),
                                ),
                                backgroundColor:
                                    Colors.white.withOpacity(0.045),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 15,
                                  vertical: 13,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(13),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: isDesktop ? 20 : 14),

                          // University identity.
                          _buildBranding(isDesktop),

                          SizedBox(height: isDesktop ? 30 : 24),

                          // Centered login panel.
                          _buildLoginCard(),

                          const SizedBox(height: 24),

                          // Service highlights.
                          _buildServiceHighlights(),

                          const SizedBox(height: 24),

                          Text(
                            'CITY UNIVERSITY  •  ABI SAMRA CAMPUS',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.47),
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.4,
                            ),
                          ),

                          const SizedBox(height: 10),

                          Text(
                            'SMART CAMPUS EXPERIENCE  /  2027',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.30),
                              fontSize: 9,
                              letterSpacing: 1.8,
                              fontWeight: FontWeight.w500,
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

  Widget _buildBranding(bool isDesktop) {
    return Column(
      children: [
        // University logo.
        Container(
          width: isDesktop ? 88 : 76,
          height: isDesktop ? 88 : 76,
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(25),
            border: Border.all(
              color: Colors.white.withOpacity(0.8),
            ),
            boxShadow: [
              BoxShadow(
                color: skyBlue.withOpacity(0.18),
                blurRadius: 36,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/cityu_logo.png',
            fit: BoxFit.contain,
            errorBuilder: (context, error, stackTrace) {
              return const Icon(
                Icons.account_balance_rounded,
                size: 50,
                color: blue,
              );
            },
          ),
        ),

        const SizedBox(height: 23),

        // 2027 edition badge.
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8,
          ),
          decoration: BoxDecoration(
            color: skyBlue.withOpacity(0.09),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(
              color: skyBlue.withOpacity(0.27),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 14,
                color: skyBlue,
              ),
              SizedBox(width: 8),
              Text(
                'THE SMART CAMPUS EXPERIENCE',
                style: TextStyle(
                  color: Color(0xFFB8D9FF),
                  fontSize: 9,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
              SizedBox(width: 8),
              Text(
                '2027',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        // Large university name.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            'SMART UNIVERSITY',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontSize: isDesktop ? 47 : 34,
              fontWeight: FontWeight.w900,
              letterSpacing: isDesktop ? 1.0 : 0.2,
              height: 1.1,
            ),
          ),
        ),

        const SizedBox(height: 13),

        Text(
          'Your campus. Your future. One platform.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: const Color(0xFFD2E1F4).withOpacity(0.88),
            fontSize: isDesktop ? 15 : 13,
            fontWeight: FontWeight.w400,
            letterSpacing: 0.25,
          ),
        ),

        const SizedBox(height: 17),

        Container(
          width: 66,
          height: 3,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            gradient: const LinearGradient(
              colors: [skyBlue, blue],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(26, 29, 26, 25),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(
          color: Colors.white.withOpacity(0.85),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.20),
            blurRadius: 45,
            offset: const Offset(0, 22),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Welcome back',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Color(0xFF122440),
              fontSize: 27,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.8,
            ),
          ),

          const SizedBox(height: 9),

          const Text(
            'Sign in to continue to your university account.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: muted,
              fontSize: 13,
              height: 1.6,
            ),
          ),

          const SizedBox(height: 29),

          const _LoginLabel('UNIVERSITY ID / EMAIL'),
          const SizedBox(height: 10),

          TextField(
            controller: universityIdController,
            keyboardType: TextInputType.emailAddress,
            textInputAction: TextInputAction.next,
            decoration: fieldDecoration(
              hint: 'Enter your university ID or email',
              icon: Icons.person_outline_rounded,
            ),
          ),

          const SizedBox(height: 21),

          const _LoginLabel('PASSWORD'),
          const SizedBox(height: 10),

          TextField(
            controller: passwordController,
            obscureText: hidePassword,
            textInputAction: TextInputAction.done,
            onSubmitted: (_) {
              if (!isLoading) login();
            },
            decoration: fieldDecoration(
              hint: 'Enter your password',
              icon: Icons.lock_outline_rounded,
              suffixIcon: IconButton(
                tooltip: hidePassword
                    ? 'Show password'
                    : 'Hide password',
                onPressed: () {
                  setState(() {
                    hidePassword = !hidePassword;
                  });
                },
                icon: Icon(
                  hidePassword
                      ? Icons.visibility_outlined
                      : Icons.visibility_off_outlined,
                  color: muted,
                  size: 20,
                ),
              ),
            ),
          ),

          const SizedBox(height: 7),

          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Forgot password feature will be added later.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: TextButton.styleFrom(
                foregroundColor: blue,
                padding: const EdgeInsets.symmetric(
                  horizontal: 4,
                  vertical: 7,
                ),
              ),
              child: const Text(
                'Forgot Password?',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),

          const SizedBox(height: 15),

          // Primary sign-in action.
          SizedBox(
            height: 56,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [
                    Color(0xFF3479EC),
                    Color(0xFF1749AD),
                  ],
                ),
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: blue.withOpacity(0.23),
                    blurRadius: 16,
                    offset: const Offset(0, 7),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: isLoading ? null : login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  disabledBackgroundColor:
                      Colors.grey.shade400,
                  shadowColor: Colors.transparent,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
                child: isLoading
                    ? const SizedBox(
                        width: 23,
                        height: 23,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: Colors.white,
                        ),
                      )
                    : const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                            ),
                          ),
                          SizedBox(width: 12),
                          Icon(
                            Icons.arrow_forward_rounded,
                            size: 20,
                          ),
                        ],
                      ),
              ),
            ),
          ),

          const SizedBox(height: 21),

          Row(
            children: [
              const Expanded(
                child: Divider(color: border, height: 1),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 13),
                child: Text(
                  'OR CONTINUE WITH',
                  style: TextStyle(
                    color: muted.withOpacity(0.85),
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.1,
                  ),
                ),
              ),
              const Expanded(
                child: Divider(color: border, height: 1),
              ),
            ],
          ),

          const SizedBox(height: 18),

          SizedBox(
            height: 53,
            child: OutlinedButton.icon(
              onPressed: isLoading ? null : continueAsGuest,
              icon: const Icon(
                Icons.person_pin_circle_outlined,
                size: 21,
              ),
              label: const Text(
                'Continue as Guest',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF254A78),
                backgroundColor: const Color(0xFFFAFBFD),
                side: const BorderSide(color: border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
            ),
          ),

          const SizedBox(height: 22),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.verified_user_outlined,
                color: Color(0xFF438567),
                size: 16,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  'A connected campus experience, all in one place.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: muted.withOpacity(0.95),
                    fontSize: 10,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceHighlights() {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 24,
      runSpacing: 14,
      children: const [
        _ServiceHighlight(
          icon: Icons.fact_check_outlined,
          label: 'Attendance',
        ),
        _ServiceHighlight(
          icon: Icons.local_parking_rounded,
          label: 'Smart Parking',
        ),
        _ServiceHighlight(
          icon: Icons.explore_outlined,
          label: 'Navigation',
        ),
      ],
    );
  }
}

class _LoginLabel extends StatelessWidget {
  final String label;

  const _LoginLabel(this.label);

  @override
  Widget build(BuildContext context) {
    return Text(
      label,
      style: const TextStyle(
        color: Color(0xFF253854),
        fontSize: 10,
        fontWeight: FontWeight.w800,
        letterSpacing: 1.1,
      ),
    );
  }
}

class _ServiceHighlight extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ServiceHighlight({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: const Color(0xFF9BCBFF),
          size: 17,
        ),
        const SizedBox(width: 7),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFFD7E5F7),
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _GlowCircle extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowCircle({
    required this.size,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: color,
        ),
      ),
    );
  }
}
