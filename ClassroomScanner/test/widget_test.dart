// Author / Project Supervisor : Omar Terro
// Student (FYP)               : Khaled Othman
import 'package:classroom_scanner/data/scanner_api.dart';
import 'package:classroom_scanner/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Login screen shows app name', (tester) async {
    await tester.pumpWidget(ClassroomScannerApp(api: ScannerApi()));
    expect(find.text('SmartUni Classroom Scanner'), findsOneWidget);
    expect(find.text('Open scanner'), findsOneWidget);
  });
}
