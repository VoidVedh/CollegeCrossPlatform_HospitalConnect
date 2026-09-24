import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/app.dart';
import 'package:hospital_connect/widgets/widgets.dart';

void main() {
  testWidgets(
      'Dashboard renders greeting, upcoming appointment card, quick actions, and top doctors',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HospitalConnectApp(useGoogleFonts: false));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Verify patient header
    expect(find.text('Hello, Aditya 👋'), findsOneWidget);
    expect(find.text('SOS 108'), findsOneWidget);

    // Verify search bar
    expect(find.text('Search doctors, specialties...'), findsOneWidget);

    // Verify upcoming appointment card
    expect(find.text('Upcoming Appointment'), findsWidgets);
    expect(find.text('Dr. Meera Nambiar'), findsWidgets);
    expect(find.text('General Medicine'), findsWidgets);

    // Verify quick action cards
    expect(find.text('Book Visit'), findsOneWidget);
    expect(find.text('Prescriptions'), findsOneWidget);
    expect(find.text('Records'), findsWidgets);
    expect(find.text('Pay Bills'), findsOneWidget);

    // Verify specialty category chips
    expect(find.text('Find by Specialty'), findsOneWidget);
    expect(
        find.widgetWithText(SpecialtyChip, 'Cardiology'), findsOneWidget);

    // Verify top specialists carousel
    expect(find.text('Top Rated Specialists'), findsOneWidget);
    expect(find.text('Consult'), findsWidgets);

    // Tap on Quick Action 'Pay Bills' -> switches tab to Bills
    await tester.tap(find.text('Pay Bills'));
    await tester.pumpAndSettle();
    expect(find.text('Bills & Payments'), findsOneWidget);
  });
}
