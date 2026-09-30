import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'helpers/pump_app.dart';

void main() {
  testWidgets('AppShell renders 5-tab NavigationBar and switches tabs',
      (WidgetTester tester) async {
    await pumpHospitalApp(tester);
    await tester.pumpAndSettle();

    // Verify tabs and initial Dashboard content
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('Doctors'), findsOneWidget);
    expect(find.text('Appointments'), findsOneWidget);
    expect(
        find.widgetWithText(NavigationDestination, 'Records'), findsOneWidget);
    expect(find.text('Bills'), findsOneWidget);
    expect(find.text('Hello, Aditya 👋'), findsOneWidget);

    // Tap 'Doctors' tab
    await tester.tap(find.text('Doctors'));
    await tester.pumpAndSettle();
    expect(find.text('Find Doctors'), findsOneWidget);

    // Tap 'Bills' tab
    await tester.tap(find.text('Bills'));
    await tester.pumpAndSettle();
    expect(find.text('Bills & Payments'), findsOneWidget);
  });
}
