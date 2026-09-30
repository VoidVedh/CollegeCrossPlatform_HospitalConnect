import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/screens/app_shell.dart';
import 'package:hospital_connect/screens/doctors/doctors_screen.dart';
import 'package:hospital_connect/screens/records/records_screen.dart';
import 'package:hospital_connect/services/slot_schedule_service.dart';
import 'package:hospital_connect/widgets/booking/time_slot_grid.dart';
import 'package:hospital_connect/widgets/common/status_badge.dart';
import 'package:hospital_connect/widgets/doctor_card.dart';
import 'helpers/pump_app.dart';

void main() {
  group('Phase 5 Accessibility & Semantics Tests', () {
    testWidgets('1. TimeSlotGrid slot cells announce time and state for screen readers', (tester) async {
      final handle = tester.ensureSemantics();
      final now = DateTime(2026, 10, 1, 9, 0);
      final slots = [
        DoctorSlot(time: '09:00 AM', dateTime: now, isBooked: false, isPast: false, isAvailable: true),
        DoctorSlot(time: '09:30 AM', dateTime: now.add(const Duration(minutes: 30)), isBooked: true, isPast: false, isAvailable: false),
        DoctorSlot(time: '10:00 AM', dateTime: now.add(const Duration(minutes: 60)), isBooked: false, isPast: false, isAvailable: true),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: TimeSlotGrid(
              slots: slots,
              selectedSlot: '10:00 AM',
              onSlotSelected: (_) {},
            ),
          ),
        ),
      );

      // Verify Semantics widgets exist with proper labels
      expect(
        find.bySemanticsLabel('09:00 AM, available'),
        findsOneWidget,
        reason: 'Available slot must announce time and available',
      );
      expect(
        find.bySemanticsLabel('09:30 AM, booked'),
        findsOneWidget,
        reason: 'Booked slot must announce time and booked',
      );
      expect(
        find.bySemanticsLabel('10:00 AM, selected'),
        findsOneWidget,
        reason: 'Selected slot must announce time and selected',
      );
      handle.dispose();
    });

    testWidgets('2. StatusBadge includes accessible semantics label', (tester) async {
      final handle = tester.ensureSemantics();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: StatusBadge.fromAppointmentStatus(AppointmentStatus.upcoming),
          ),
        ),
      );

      expect(
        find.bySemanticsLabel('Status: Upcoming'),
        findsOneWidget,
      );
      handle.dispose();
    });

    testWidgets('3. DoctorCard buttons have at least 48dp minimum touch targets', (tester) async {
      const doctor = DoctorModel(
        id: 'doc-test-1',
        name: 'Dr. Jane Smith',
        specialty: 'Cardiology',
        experienceYears: 12,
        rating: 4.9,
        reviews: [],
        consultationFee: 750,
        hospitalName: 'Apollo Hospital',
        clinicAddress: 'OPD Block A',
        about: 'Senior Cardiologist with extensive clinical practice.',
        availableSlots: [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: DoctorCard(
              doctor: doctor,
              onTap: () {},
              onBookVisit: () {},
            ),
          ),
        ),
      );

      // Check Profile and Book Visit buttons touch target sizes
      final profileBtn = tester.getSize(find.widgetWithText(OutlinedButton, 'Profile'));
      final bookVisitBtn = tester.getSize(find.widgetWithText(FilledButton, 'Book Visit'));

      expect(profileBtn.height, greaterThanOrEqualTo(48.0));
      expect(bookVisitBtn.height, greaterThanOrEqualTo(48.0));
    });

    testWidgets('4. TimeSlotGrid slot cells have at least 48dp touch target height', (tester) async {
      final now = DateTime(2026, 10, 1, 9, 0);
      final slots = [
        DoctorSlot(time: '09:00 AM', dateTime: now, isBooked: false, isPast: false, isAvailable: true),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 360,
              child: TimeSlotGrid(
                slots: slots,
                selectedSlot: null,
                onSlotSelected: (_) {},
              ),
            ),
          ),
        ),
      );

      final slotFinder = find.text('09:00 AM');
      final inkWellFinder = find.ancestor(of: slotFinder, matching: find.byType(InkWell));
      final inkWellSize = tester.getSize(inkWellFinder);
      expect(inkWellSize.height, greaterThanOrEqualTo(48.0));
    });
  });

  group('Phase 5 Responsiveness & Adaptive Navigation Tests', () {
    testWidgets('5. AppShell uses NavigationRail on wide screens (>= 720dp)', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpHospitalApp(
        tester,
        home: const AppShell(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
    });

    testWidgets('6. AppShell uses NavigationBar on narrow screens (< 720dp)', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpHospitalApp(
        tester,
        home: const AppShell(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
    });

    testWidgets('7. DoctorsScreen displays two-pane master-detail layout on wide screens', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpHospitalApp(
        tester,
        home: const DoctorsScreen(),
      );
      await tester.pumpAndSettle();

      // Should show the doctors list and an embedded doctor detail pane with Doctor Profile
      expect(find.text('Find Doctors'), findsOneWidget);
      expect(find.text('Doctor Profile'), findsOneWidget);
    });

    testWidgets('8. RecordsScreen displays two-pane master-detail layout on wide screens', (tester) async {
      tester.view.physicalSize = const Size(1024, 768);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpHospitalApp(
        tester,
        home: const RecordsScreen(),
      );
      await tester.pumpAndSettle();

      expect(find.text('Medical Records'), findsOneWidget);
      expect(find.text('Medical Record Details'), findsOneWidget);
    });

    testWidgets('9. No overflow on small screen (320x568) at 2.0x text scale', (tester) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.resetPhysicalSize);

      await pumpHospitalApp(
        tester,
        home: const MediaQuery(
          data: MediaQueryData(
            size: Size(320, 568),
            textScaler: TextScaler.linear(2.0),
          ),
          child: AppShell(),
        ),
      );
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });
  });
}
