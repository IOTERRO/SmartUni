// Author / Project Supervisor : Omar Terro
// GitHub                      : https://github.com/IOTERRO
// Website                     : https://omarterro.fr
// Student (FYP)               : Khaled Othman
// Date                        : 14 October 2026
// Project                     : SmartUni - Classroom Scanner
import 'package:flutter/material.dart';

import 'app/theme.dart';
import 'core/config/app_config.dart';
import 'data/scanner_api.dart';
import 'features/login/login_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(ClassroomScannerApp(api: ScannerApi()));
}

class ClassroomScannerApp extends StatelessWidget {
  const ClassroomScannerApp({super.key, required this.api});

  final ScannerApi api;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      theme: buildScannerTheme(),
      home: LoginScreen(api: api),
    );
  }
}
