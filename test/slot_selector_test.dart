import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/widgets/widgets.dart';

void main() {
  testWidgets('SlotSelector allows picking dates and available time slots',
      (WidgetTester tester) async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    DateTime chosenDate = tomorrow;
    String? chosenSlot;

    final doctor = DoctorModel(
      id: 'DOC-01',
      name: 'Dr. Ananya Sharma',
      specialty: 'Cardiology',
      rating: 4.9,
      experienceYears: 14,
      hospitalName: 'Apollo Speciality Hospital',
      clinicAddress: 'Bannerghatta Road, Bengaluru',
      consultationFee: 800.0,
      availableSlots: [
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 9, 0),
        DateTime(tomorrow.year, tomorrow.month, tomorrow.day, 10, 0),
      ],
      about: 'Senior Cardiologist',
      reviews: [],
    );

    // One slot already booked
    final existingAppointments = [
      AppointmentModel(
        id: 'APT-111111',
        doctorId: 'DOC-01',
        doctorName: 'Dr. Ananya Sharma',
        doctorSpecialty: 'Cardiology',
        patientName: 'Test Patient',
        patientAge: 30,
        patientPhone: '9876543210',
        appointmentDate: tomorrow,
        timeSlot: '09:00 AM',
        status: AppointmentStatus.upcoming,
        symptomsNote: 'Chest pain',
      ),
    ];

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return SlotSelector(
                doctor: doctor,
                selectedDate: chosenDate,
                selectedSlot: chosenSlot,
                existingAppointments: existingAppointments,
                onDateSelected: (date) {
                  setState(() => chosenDate = date);
                },
                onSlotSelected: (slot) {
                  setState(() => chosenSlot = slot);
                },
              );
            },
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Date selector header
    expect(find.text('Select Date'), findsOneWidget);
    expect(find.text('Select Time Slot'), findsOneWidget);

    // Verify time slots are rendered
    expect(find.text('09:00 AM'), findsOneWidget);
    expect(find.text('10:00 AM'), findsOneWidget);

    // Tapping '10:00 AM' (which is available) should select it
    await tester.tap(find.text('10:00 AM'));
    await tester.pumpAndSettle();
    expect(chosenSlot, equals('10:00 AM'));

    // Tapping '09:00 AM' (which is booked) should not select it
    await tester.tap(find.text('09:00 AM'));
    await tester.pumpAndSettle();
    expect(chosenSlot, equals('10:00 AM')); // Still 10:00 AM
  });
}
