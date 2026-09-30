import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/core/theme/app_theme.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/providers.dart';
import 'package:hospital_connect/services/mock/mock_services.dart';
import 'package:hospital_connect/widgets/appointment_confirmation_dialog.dart';
import 'package:provider/provider.dart';

void main() {
  late MockDataService mockData;
  late MockDoctorRepository doctorRepo;
  late MockAppointmentRepository appointmentRepo;
  late MockBillRepository billRepo;
  late AppointmentProvider appointmentProvider;

  setUp(() {
    mockData = MockDataService();
    doctorRepo = MockDoctorRepository(mockData);
    appointmentRepo = MockAppointmentRepository(mockData);
    billRepo = MockBillRepository(mockData);
    appointmentProvider = AppointmentProvider(
      appointmentRepo,
      doctorRepository: doctorRepo,
      billRepository: billRepo,
    );
  });

  tearDown(() {
    appointmentProvider.dispose();
  });

  test(
      'AppointmentProvider.bookAppointment creates APT-XXXXXX, marks slot unavailable, and creates pending bill',
      () async {
    final now = DateTime.now();
    final appointmentDate =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 2));
    const timeSlot = '10:00 AM';

    // Verify initial bills count
    final initialBills = await billRepo.getBills();
    final initialBillsCount = initialBills.length;

    // Book appointment
    final booked = await appointmentProvider.bookAppointment(
      doctorId: 'DOC-01',
      doctorName: 'Dr. Rajesh Sharma',
      doctorSpecialty: 'Cardiology',
      patientName: 'Rohan Mehra',
      patientAge: 32,
      patientPhone: '9876543210',
      appointmentDate: appointmentDate,
      timeSlot: timeSlot,
      symptomsNote: 'Mild palpitations after workout',
      consultationFee: 800.0,
    );

    // 1. Verify ID format APT-XXXXXX
    expect(booked.id, matches(r'^APT-[A-Z0-9]{6}$'));
    expect(booked.status, equals(AppointmentStatus.upcoming));
    expect(booked.patientName, equals('Rohan Mehra'));

    // 2. Verify appointment added to provider
    expect(appointmentProvider.appointments.first.id, equals(booked.id));

    // 3. Verify linked pending bill was created
    final updatedBills = await billRepo.getBills();
    expect(updatedBills.length, equals(initialBillsCount + 1));
    final linkedBill =
        updatedBills.firstWhere((b) => b.appointmentId == booked.id);
    expect(linkedBill.status, equals(BillStatus.pending));
    expect(linkedBill.consultationFee, equals(800.0));
    expect(linkedBill.totalAmount, equals(800.0 + (800.0 * 0.18).roundToDouble()));

    // 4. Verify slot is marked unavailable for doctor
    final doctor = await doctorRepo.getDoctorById('DOC-01');
    expect(doctor, isNotNull);
    final slotDateTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      10,
      0,
    );
    expect(
      doctor!.availableSlots.any((s) => s.isAtSameMomentAs(slotDateTime)),
      isFalse,
    );
  });

  test('AppointmentProvider.cancelAppointment frees the doctor slot',
      () async {
    final now = DateTime.now();
    final appointmentDate =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 3));
    const timeSlot = '11:00 AM';

    final booked = await appointmentProvider.bookAppointment(
      doctorId: 'DOC-02',
      doctorName: 'Dr. Anita Roy',
      doctorSpecialty: 'Cardiology',
      patientName: 'Meera Sen',
      patientAge: 45,
      patientPhone: '9812345678',
      appointmentDate: appointmentDate,
      timeSlot: timeSlot,
      symptomsNote: 'Routine checkup for blood pressure',
      consultationFee: 900.0,
    );

    // Cancel appointment
    final cancelled = await appointmentProvider.cancelAppointment(booked.id);
    expect(cancelled.status, equals(AppointmentStatus.cancelled));

    // Doctor slot should be freed (available again)
    final doctor = await doctorRepo.getDoctorById('DOC-02');
    final slotDateTime = DateTime(
      appointmentDate.year,
      appointmentDate.month,
      appointmentDate.day,
      11,
      0,
    );
    expect(
      doctor!.availableSlots.any((s) => s.isAtSameMomentAs(slotDateTime)),
      isTrue,
    );
  });

  testWidgets(
      'AppointmentConfirmationDialog presents breakdown and success modal upon confirmation',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final doctor = mockData.doctors.first;

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppointmentProvider>.value(
            value: appointmentProvider,
          ),
          ChangeNotifierProvider<DoctorProvider>(
            create: (_) => DoctorProvider(doctorRepo),
          ),
          ChangeNotifierProvider<BillProvider>(
            create: (_) => BillProvider(
              billRepository: billRepo,
              paymentGateway: MockPaymentGateway(),
            ),
          ),
        ],
        child: MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: Scaffold(
            body: Builder(
              builder: (ctx) => Center(
                child: ElevatedButton(
                  onPressed: () {
                    showAppointmentConfirmationDialog(
                      context: ctx,
                      doctor: doctor,
                      appointmentDate: DateTime(2026, 10, 15),
                      timeSlot: '10:00 AM',
                      patientName: 'Aarav Gupta',
                      patientAge: 6,
                      patientPhone: '9876500000',
                      symptomsNote: 'Mild cough and cold since yesterday',
                    );
                  },
                  child: const Text('Open Dialog'),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Open confirmation dialog
    await tester.tap(find.text('Open Dialog'));
    await tester.pumpAndSettle();

    // Verify dialog content
    expect(find.text('Confirm Appointment'), findsOneWidget);
    expect(find.text(doctor.name), findsOneWidget);
    expect(find.text('Aarav Gupta (6 yrs)'), findsOneWidget);
    expect(find.text('₹${doctor.consultationFee.round()}'), findsWidgets); // consultation fee

    // Tap confirm button
    await tester.tap(find.byKey(const Key('confirm_booking_dialog_button')));
    await tester.pump();
    for (int i = 0; i < 20; i++) {
      await tester.pump(const Duration(milliseconds: 100));
      if (find.text('Appointment Confirmed!').evaluate().isNotEmpty) {
        break;
      }
    }
    await tester.pumpAndSettle();

    // Verify Success Modal appears with generated APT- ID
    expect(find.text('Appointment Confirmed!'), findsOneWidget);
    expect(find.byKey(const Key('confirmed_appointment_id_text')), findsOneWidget);
    expect(find.byKey(const Key('view_appointments_modal_button')), findsOneWidget);
  });
}
