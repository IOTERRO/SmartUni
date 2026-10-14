import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'app/smart_uni_app.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Show runtime errors on screen instead of a blank white page (web).
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    if (kDebugMode) {
      debugPrint('FlutterError: ${details.exceptionAsString()}');
    }
  };

  ErrorWidget.builder = (details) {
    return Material(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'UI error:\n${details.exception}',
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.red, fontSize: 14),
          ),
        ),
      ),
    );
  };

  runApp(const SmartUniApp());
}
