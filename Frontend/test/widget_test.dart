/// Author / Project Supervisor : Omar Terro
/// Student (FYP)               : Khaled Othman
/// Date                        : 14 October 2026
/// Project                     : SmartUni — Smart University CityU
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_university_cityu/app/smart_uni_app.dart';

void main() {
  testWidgets('Welcome screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SmartUniApp());
    expect(find.text('Login Student'), findsOneWidget);
    expect(find.text('Continue as Guest'), findsOneWidget);
    expect(find.text('Admin'), findsOneWidget);
  });
}
