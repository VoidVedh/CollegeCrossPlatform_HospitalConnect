import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/providers.dart';
import 'package:hospital_connect/screens/appointments/booking_screen.dart';
import 'package:hospital_connect/services/booking_coordinator.dart';
import 'package:hospital_connect/services/mock/mock_services.dart';
import 'package:hospital_connect/widgets/appointment_confirmation_dialog.dart';
import 'helpers/pump_app.dart';

void main() {
  group('End-to-End HospitalConnect Workflow Integration Tests', () {
    late MockDataService dataService;
    late MockDoctorRepository doctorRepo;
    late MockAppointmentRepository appointmentRepo;
    late MockBillRepository billRepo;
    late MockPaymentGateway paymentGateway;
    late DoctorProvider doctorProvider;
    late AppointmentProvider appointmentProvider;
    late BillProvider billProvider;
    late BookingCoordinator coordinator;

    setUp(() {
      dataService = MockDataService();
      doctorRepo = MockDoctorRepository(dataService);
      appointmentRepo = MockAppointmentRepository(dataService);
      billRepo = MockBillRepository(dataService);
      paymentGateway = MockPaymentGateway();

      doctorProvider = DoctorProvider(doctorRepo);
      appointmentProvider = AppointmentProvider(
        appointmentRepo,
        doctorRepository: doctorRepo,
        billRepository: billRepo,
      );

      billProvider = BillProvider(
        billRepository: billRepo,
        paymentGateway: paymentGateway,
      );

      coordinator = BookingCoordinator(
        appointmentProvider: appointmentProvider,
        doctorProvider: doctorProvider,
        billProvider: billProvider,
      );
    });

    test('1. Full Patient Journey: Discover -> Book -> Auto-Invoice -> Pay -> Receipt', () async {
      await Future.wait([
        doctorProvider.loadDoctors(),
        appointmentProvider.loadAppointments(),
        billProvider.loadBills(),
      ]);

      // 1. Doctor Discovery
      final doctors = doctorProvider.doctors;
      expect(doctors.isNotEmpty, isTrue);
      final cardiologist = doctors.firstWhere((d) => d.specialty.toLowerCase().contains('cardio'));
      expect(cardiologist.name, isNotEmpty);
      expect(cardiologist.consultationFee, greaterThan(0));

      // 2. Book an Appointment via BookingCoordinator
      final bookingDate = DateTime.now().add(const Duration(days: 2));
      const bookingSlot = '10:00 AM';
      final initialUpcomingCount = appointmentProvider.upcomingAppointments.length;
      final initialBillsCount = billProvider.bills.length;

      final bookedAppointment = await coordinator.bookAppointment(
        doctorId: cardiologist.id,
        doctorName: cardiologist.name,
        doctorSpecialty: cardiologist.specialty,
        patientName: 'Aarav Patel',
        patientAge: 29,
        patientPhone: '+91 98765 43210',
        appointmentDate: bookingDate,
        timeSlot: bookingSlot,
        symptomsNote: 'Routine cardiology wellness screening',
        consultationFee: cardiologist.consultationFee,
      );

      // Verify Appointment State
      expect(bookedAppointment.id.startsWith('APT-'), isTrue);
      expect(bookedAppointment.status, equals(AppointmentStatus.upcoming));
      expect(appointmentProvider.upcomingAppointments.length, equals(initialUpcomingCount + 1));
      expect(appointmentProvider.upcomingAppointments.first.id, equals(bookedAppointment.id));

      // Verify Auto-generated Invoice
      expect(billProvider.bills.length, equals(initialBillsCount + 1));
      final generatedBill = billProvider.bills.firstWhere(
        (b) => b.appointmentId == bookedAppointment.id,
      );
      expect(generatedBill.status, equals(BillStatus.pending));
      expect(generatedBill.consultationFee, equals(cardiologist.consultationFee));
      expect(generatedBill.totalAmount, greaterThan(0));

      // 3. Process payment through UPI simulation
      final paymentResult = await billProvider.payBill(
        billId: generatedBill.id,
        method: PaymentMethodType.upi,
        details: {'upiId': 'aarav.patel@okhdfcbank'},
      );

      expect(paymentResult.isSuccess, isTrue);
      expect(paymentResult.transactionId.isNotEmpty, isTrue);

      // 4. Verify bill receipt & settled status
      final settledBill = billProvider.getBillById(generatedBill.id);
      expect(settledBill, isNotNull);
      expect(settledBill!.status, equals(BillStatus.paid));
      expect(settledBill.paymentMethod, equals(PaymentMethodType.upi));
      expect(settledBill.paidAt, isNotNull);
    });

    test('2. Reschedule Lifecycle: Frees old slot, allocates new slot, preserves invoice', () async {
      await Future.wait([
        doctorProvider.loadDoctors(),
        appointmentProvider.loadAppointments(),
        billProvider.loadBills(),
      ]);

      final doctor = doctorProvider.doctors.first;
      final originalDate = DateTime.now().add(const Duration(days: 3));
      const originalSlot = '09:30 AM';
      final newDate = DateTime.now().add(const Duration(days: 4));
      const newSlot = '11:00 AM';

      // Book original appointment
      final appointment = await coordinator.bookAppointment(
        doctorId: doctor.id,
        doctorName: doctor.name,
        doctorSpecialty: doctor.specialty,
        patientName: 'Meera Rao',
        patientAge: 34,
        patientPhone: '+91 91234 56789',
        appointmentDate: originalDate,
        timeSlot: originalSlot,
        symptomsNote: 'Initial consultation',
        consultationFee: doctor.consultationFee,
      );

      expect(appointment.timeSlot, equals(originalSlot));

      // Reschedule to new date and time
      final rescheduled = await coordinator.rescheduleAppointment(
        appointmentId: appointment.id,
        newDate: newDate,
        newTimeSlot: newSlot,
      );

      expect(rescheduled.id, equals(appointment.id));
      expect(rescheduled.appointmentDate.day, equals(newDate.day));
      expect(rescheduled.timeSlot, equals(newSlot));
      expect(rescheduled.status, equals(AppointmentStatus.upcoming));

      // Verify updated in appointmentProvider
      final current = appointmentProvider.getAppointmentById(appointment.id);
      expect(current!.timeSlot, equals(newSlot));
    });

    test('3. Cancellation Lifecycle: Frees slot, marks cancelled, voids pending bill', () async {
      await Future.wait([
        doctorProvider.loadDoctors(),
        appointmentProvider.loadAppointments(),
        billProvider.loadBills(),
      ]);

      final doctor = doctorProvider.doctors.first;
      final bookingDate = DateTime.now().add(const Duration(days: 5));
      const bookingSlot = '02:00 PM';

      final appointment = await coordinator.bookAppointment(
        doctorId: doctor.id,
        doctorName: doctor.name,
        doctorSpecialty: doctor.specialty,
        patientName: 'Dev Sharma',
        patientAge: 40,
        patientPhone: '+91 99887 76655',
        appointmentDate: bookingDate,
        timeSlot: bookingSlot,
        symptomsNote: 'Pre-surgery follow-up',
        consultationFee: doctor.consultationFee,
      );

      // Verify linked bill is initially pending/unpaid
      final bill = billProvider.bills.firstWhere((b) => b.appointmentId == appointment.id);
      expect(bill.status, equals(BillStatus.pending));

      // Cancel appointment
      final cancelled = await coordinator.cancelAppointment(appointment.id);
      expect(cancelled.status, equals(AppointmentStatus.cancelled));

      // Verify appointment is no longer in upcoming list
      expect(
        appointmentProvider.upcomingAppointments.any((a) => a.id == appointment.id),
        isFalse,
      );

      // Verify bill was voided/cancelled
      final updatedBill = billProvider.getBillById(bill.id);
      expect(updatedBill!.status, equals(BillStatus.cancelled));
    });

    testWidgets('4. UI Stepper Booking & Confirmation Dialog flow', (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      // Trigger loads and advance fake async timer
      doctorProvider.loadDoctors();
      appointmentProvider.loadAppointments();
      billProvider.loadBills();
      await tester.pump(const Duration(milliseconds: 300));

      final doctor = dataService.doctors.first;

      await pumpHospitalApp(
        tester,
        home: Scaffold(
          body: BookingScreen(doctor: doctor),
        ),
        doctorProvider: doctorProvider,
        appointmentProvider: appointmentProvider,
        billProvider: billProvider,
        bookingCoordinator: coordinator,
      );
      await tester.pump(const Duration(milliseconds: 300));

      // Step 1: Select an available time slot (10:30 AM is available for DOC-01 tomorrow)
      expect(find.text('Select Time Slot'), findsOneWidget);
      final slotFinder = find.text('10:30 AM');
      expect(slotFinder, findsOneWidget);
      await tester.tap(slotFinder);
      await tester.pump(const Duration(milliseconds: 200));

      // Step 2: Fill patient details using explicit Keys
      await tester.enterText(
        find.byKey(const Key('patient_name_field')),
        'Kavita Verma',
      );
      await tester.enterText(find.byKey(const Key('patient_age_field')), '31');
      await tester.enterText(
        find.byKey(const Key('patient_phone_field')),
        '9876543210',
      );
      await tester.enterText(
        find.byKey(const Key('patient_symptoms_field')),
        'Routine checkup consultation',
      );
      await tester.pump(const Duration(milliseconds: 200));

      // Tap Proceed / Review button (scroll into view if needed)
      final proceedBtn = find.byKey(const Key('proceed_booking_button'));
      expect(proceedBtn, findsOneWidget);
      await tester.ensureVisible(proceedBtn);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(proceedBtn);
      await tester.pump(const Duration(milliseconds: 300));

      // Confirmation Dialog opens
      expect(find.byType(AppointmentConfirmationDialog), findsOneWidget);
      expect(find.text('Confirm Appointment'), findsOneWidget);

      // Confirm Booking in Dialog
      final confirmBtn = find.byKey(const Key('confirm_booking_dialog_button'));
      expect(confirmBtn, findsOneWidget);
      await tester.ensureVisible(confirmBtn);
      await tester.pump(const Duration(milliseconds: 100));
      await tester.tap(confirmBtn);
      for (int i = 0; i < 20; i++) {
        await tester.pump(const Duration(milliseconds: 100));
        if (find.text('Appointment Confirmed!').evaluate().isNotEmpty) {
          break;
        }
      }

      // Verify success modal and appointment in provider
      expect(find.text('Appointment Confirmed!'), findsOneWidget);
      expect(
        appointmentProvider.appointments.any((a) => a.patientName == 'Kavita Verma'),
        isTrue,
      );
    });
  });
}
