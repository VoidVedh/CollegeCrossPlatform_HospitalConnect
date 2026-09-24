import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/widgets/widgets.dart';

void main() {
  testWidgets('DoctorCard displays details and handles actions',
      (WidgetTester tester) async {
    bool tappedProfile = false;
    bool tappedBook = false;

    final doctor = DoctorModel(
      id: 'DOC-01',
      name: 'Dr. Ananya Sharma',
      specialty: 'Cardiology',
      rating: 4.9,
      experienceYears: 14,
      hospitalName: 'Apollo Speciality Hospital',
      clinicAddress: 'Bannerghatta Road, Bengaluru',
      consultationFee: 800.0,
      availableSlots: [DateTime.now().add(const Duration(days: 1))],
      about: 'Senior Cardiologist',
      reviews: [],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: DoctorCard(
            doctor: doctor,
            onTap: () => tappedProfile = true,
            onBookVisit: () => tappedBook = true,
          ),
        ),
      ),
    );

    // Verify info display
    expect(find.text('Dr. Ananya Sharma'), findsOneWidget);
    expect(find.text('Cardiology'), findsOneWidget);
    expect(find.text('4.9'), findsOneWidget);
    expect(find.text('14 yrs experience'), findsOneWidget);
    expect(find.text('Apollo Speciality Hospital'), findsOneWidget);
    expect(find.text('₹800'), findsOneWidget);

    // Test taps
    await tester.tap(find.text('Profile'));
    await tester.pumpAndSettle();
    expect(tappedProfile, isTrue);

    await tester.tap(find.text('Book Visit'));
    await tester.pumpAndSettle();
    expect(tappedBook, isTrue);
  });
}
