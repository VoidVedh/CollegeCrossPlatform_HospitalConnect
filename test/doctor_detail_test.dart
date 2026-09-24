import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/screens/appointments/booking_screen.dart';
import 'package:hospital_connect/screens/doctors/doctor_detail_screen.dart';

void main() {
  testWidgets('DoctorDetailScreen renders biography, reviews, and booking entrance',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final doctor = DoctorModel(
      id: 'DOC-01',
      name: 'Dr. Ananya Sharma',
      specialty: 'Cardiology',
      rating: 4.9,
      experienceYears: 14,
      hospitalName: 'Apollo Speciality Hospital',
      clinicAddress: 'Bannerghatta Main Road, Bengaluru',
      consultationFee: 800.0,
      availableSlots: [DateTime.now().add(const Duration(days: 1))],
      about: 'Senior interventional cardiologist with 14 years of practice.',
      reviews: [
        ReviewModel(
          id: 'REV-01',
          authorName: 'Ramesh Patel',
          rating: 5.0,
          comment: 'Exceptional doctor and very polite staff.',
          date: DateTime(2026, 9, 1),
        ),
      ],
    );

    await tester.pumpWidget(
      MaterialApp(
        home: DoctorDetailScreen(doctor: doctor),
      ),
    );
    await tester.pumpAndSettle();

    // Verify header and basic info
    expect(find.text('Dr. Ananya Sharma'), findsOneWidget);
    expect(find.text('Cardiology'), findsOneWidget);
    expect(find.text('14+ Yrs'), findsOneWidget);
    expect(find.text('4.9 ★'), findsOneWidget);

    // Verify bio and location
    expect(find.text('About Doctor'), findsOneWidget);
    expect(find.text('Senior interventional cardiologist with 14 years of practice.'),
        findsOneWidget);
    expect(find.text('Bannerghatta Main Road, Bengaluru'), findsOneWidget);

    // Verify review
    expect(find.text('Ramesh Patel'), findsOneWidget);
    expect(find.text('Exceptional doctor and very polite staff.'), findsOneWidget);

    // Verify fee and bottom bar button
    expect(find.text('₹800'), findsOneWidget);
    expect(find.text('Book Appointment'), findsOneWidget);

    // Tap Book Appointment
    await tester.tap(find.text('Book Appointment'));
    await tester.pumpAndSettle();

    expect(find.byType(BookingScreen), findsOneWidget);
  });
}
