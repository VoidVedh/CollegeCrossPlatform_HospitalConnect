import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/app.dart';
import 'package:hospital_connect/widgets/widgets.dart';

void main() {
  testWidgets('DoctorsScreen searches, filters by specialty, and handles empty state',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const HospitalConnectApp(useGoogleFonts: false));
    await tester.pump(const Duration(milliseconds: 200));
    await tester.pumpAndSettle();

    // Switch to Doctors tab
    await tester.tap(find.text('Doctors'));
    await tester.pumpAndSettle();

    expect(find.text('Find Doctors'), findsOneWidget);
    expect(find.byType(DoctorCard), findsWidgets);

    // Filter by Neurology
    await tester.tap(find.widgetWithText(SpecialtyChip, 'Neurology'));
    await tester.pumpAndSettle();

    expect(find.text('Dr. Priya Sundaram'), findsOneWidget);
    expect(find.text('Dr. Vikram Malhotra'), findsOneWidget);
    expect(find.text('Dr. Ananya Sharma'), findsNothing);

    // Enter non-existent search query to test empty state
    await tester.enterText(
        find.widgetWithText(SearchBar, 'Search by doctor, specialty, hospital...'),
        'NonExistentDoctorXYZ');
    await tester.pumpAndSettle();

    expect(find.text('No Doctors Found'), findsOneWidget);

    // Tap Clear All Filters
    await tester.tap(find.text('Clear All Filters'));
    await tester.pumpAndSettle();

    // Verify list is restored
    expect(find.text('No Doctors Found'), findsNothing);
    expect(find.byType(DoctorCard), findsWidgets);
  });
}
