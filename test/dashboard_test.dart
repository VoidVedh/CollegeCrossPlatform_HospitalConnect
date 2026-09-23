import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/app.dart';

void main() {
  testWidgets(
      'Dashboard renders patient header, search bar, and specialty chips',
      (WidgetTester tester) async {
    await tester.pumpWidget(const HospitalConnectApp(useGoogleFonts: false));
    await tester.pumpAndSettle();

    // Verify patient header
    expect(find.text('Hello, Aditya 👋'), findsOneWidget);
    expect(find.text('SOS 108'), findsOneWidget);

    // Verify search bar
    expect(find.text('Search doctors, specialties...'), findsOneWidget);

    // Verify specialty chips
    expect(find.text('Specialties'), findsOneWidget);
    expect(find.text('All'), findsOneWidget);
    expect(find.text('Cardiology'), findsOneWidget);

    // Tap on Cardiology chip
    await tester.tap(find.text('Cardiology'));
    await tester.pumpAndSettle();

    // Verify search bar input
    await tester.enterText(find.byType(SearchBar), 'Sharma');
    await tester.pumpAndSettle();
    expect(find.text('Sharma'), findsOneWidget);
  });
}
