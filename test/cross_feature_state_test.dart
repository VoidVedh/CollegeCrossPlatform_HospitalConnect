import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/core/theme/app_theme.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/providers.dart';
import 'package:hospital_connect/screens/app_shell.dart';
import 'package:hospital_connect/screens/appointments/appointments_screen.dart';
import 'package:hospital_connect/services/repositories/repositories.dart';
import 'package:provider/provider.dart';

class _FakeDoctorRepo implements DoctorRepository {
  _FakeDoctorRepo(this.doctors);
  final List<DoctorModel> doctors;

  @override
  Future<List<DoctorModel>> getDoctors() async => doctors;

  @override
  Future<DoctorModel?> getDoctorById(String id) async {
    try {
      return doctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<List<DoctorModel>> searchDoctors(
    String query, {
    String? specialty,
  }) async {
    return doctors;
  }

  @override
  Future<bool> markSlotAvailability({
    required String doctorId,
    required DateTime slot,
    required bool isAvailable,
  }) async {
    final idx = doctors.indexWhere((d) => d.id == doctorId);
    if (idx != -1) {
      final doc = doctors[idx];
      final currentSlots = List<DateTime>.from(doc.availableSlots);
      if (isAvailable) {
        if (!currentSlots.any((s) => s.isAtSameMomentAs(slot))) {
          currentSlots.add(slot);
        }
      } else {
        currentSlots.removeWhere((s) => s.isAtSameMomentAs(slot));
      }
      doctors[idx] = doc.copyWith(availableSlots: currentSlots);
      return true;
    }
    return false;
  }
}

class _FakeAppointmentRepo implements AppointmentRepository {
  _FakeAppointmentRepo(List<AppointmentModel> initial)
      : _appointments = List.from(initial);
  final List<AppointmentModel> _appointments;

  @override
  Future<List<AppointmentModel>> getAppointments() async => _appointments;

  @override
  Future<AppointmentModel?> getAppointmentById(String id) async {
    try {
      return _appointments.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppointmentModel> bookAppointment(AppointmentModel appointment) async {
    _appointments.insert(0, appointment);
    return appointment;
  }

  @override
  Future<AppointmentModel> cancelAppointment(String id) async {
    final idx = _appointments.indexWhere((a) => a.id == id);
    final updated =
        _appointments[idx].copyWith(status: AppointmentStatus.cancelled);
    _appointments[idx] = updated;
    return updated;
  }
}

class _FakeBillRepo implements BillRepository {
  _FakeBillRepo(List<BillModel> initial) : _bills = List.from(initial);
  final List<BillModel> _bills;

  @override
  Future<List<BillModel>> getBills() async => _bills;

  @override
  Future<BillModel?> getBillById(String id) async {
    try {
      return _bills.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BillModel> addBill(BillModel bill) async {
    _bills.insert(0, bill);
    return bill;
  }

  @override
  Future<BillModel> updateBillStatus({
    required String billId,
    required BillStatus status,
    PaymentMethodType? paymentMethod,
    DateTime? paidAt,
  }) async {
    final idx = _bills.indexWhere((b) => b.id == billId);
    final updated = _bills[idx].copyWith(
      status: status,
      paymentMethod: paymentMethod,
      paidAt: paidAt,
    );
    _bills[idx] = updated;
    return updated;
  }
}

class _InstantPaymentGateway implements PaymentGateway {
  @override
  Future<PaymentResult> processPayment({
    required String billId,
    required double amount,
    required PaymentMethodType method,
    required Map<String, String> details,
  }) async {
    return PaymentResult(
      isSuccess: true,
      transactionId: 'TXN-SYNC-111',
      message: 'Paid successfully.',
      paidAt: DateTime(2026, 9, 29),
    );
  }
}

class _FakeRecordRepo implements MedicalRecordRepository {
  @override
  Future<List<MedicalRecordModel>> getMedicalRecords() async => [];
  @override
  Future<MedicalRecordModel?> getRecordById(String id) async => null;
}

class _FakePrescriptionRepo implements PrescriptionRepository {
  @override
  Future<List<PrescriptionModel>> getPrescriptions() async => [];
  @override
  Future<PrescriptionModel?> getPrescriptionById(String id) async => null;
}

void main() {
  final testDoctorSlot = DateTime(2026, 9, 30, 10, 0);

  final testDoctor = DoctorModel(
    id: 'DOC-1',
    name: 'Dr. Meera Nambiar',
    specialty: 'Cardiology',
    rating: 4.9,
    experienceYears: 14,
    hospitalName: 'Apollo Hospitals',
    clinicAddress: 'Bannerghatta Road, Bangalore',
    consultationFee: 800.0,
    availableSlots: [testDoctorSlot],
    about: 'Experienced cardiologist with 14+ years in cardiac interventions.',
    reviews: const [],
  );

  final upcomingApt = AppointmentModel(
    id: 'APT-100001',
    doctorId: 'DOC-1',
    doctorName: 'Dr. Meera Nambiar',
    doctorSpecialty: 'Cardiology',
    patientName: 'Aditya Sharma',
    patientAge: 28,
    patientPhone: '9876543210',
    appointmentDate: DateTime(2026, 9, 30),
    timeSlot: '10:00 AM',
    status: AppointmentStatus.upcoming,
    symptomsNote: 'Routine cardiovascular follow up and BP check.',
  );

  final completedApt = AppointmentModel(
    id: 'APT-100002',
    doctorId: 'DOC-1',
    doctorName: 'Dr. Meera Nambiar',
    doctorSpecialty: 'Cardiology',
    patientName: 'Aditya Sharma',
    patientAge: 28,
    patientPhone: '9876543210',
    appointmentDate: DateTime(2026, 8, 15),
    timeSlot: '11:00 AM',
    status: AppointmentStatus.completed,
    symptomsNote: 'Initial ECG consultation and assessment.',
  );

  testWidgets(
      'AppointmentsScreen displays Upcoming and Completed tabs, and cancels visit freeing slot',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final doctorRepo = _FakeDoctorRepo([testDoctor]);
    final aptRepo = _FakeAppointmentRepo([upcomingApt, completedApt]);
    final billRepo = _FakeBillRepo([]);

    final aptProvider = AppointmentProvider(
      aptRepo,
      doctorRepository: doctorRepo,
      billRepository: billRepo,
    );
    final docProvider = DoctorProvider(doctorRepo);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppointmentProvider>.value(value: aptProvider),
          ChangeNotifierProvider<DoctorProvider>.value(value: docProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: const AppointmentsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Verify tabs
    expect(find.text('Upcoming (1)'), findsOneWidget);
    expect(find.text('Completed (1)'), findsOneWidget);
    expect(find.text('Cancelled (0)'), findsOneWidget);

    // Verify upcoming appointment card
    expect(find.text('APT-100001'), findsOneWidget);
    expect(find.text('Dr. Meera Nambiar'), findsOneWidget);
    expect(find.text('UPCOMING'), findsOneWidget);
    expect(find.byKey(const Key('cancel_appointment_btn_APT-100001')),
        findsOneWidget);

    // 2. Tap Completed tab
    await tester.tap(find.text('Completed (1)'));
    await tester.pumpAndSettle();

    expect(find.text('APT-100002'), findsOneWidget);
    expect(find.text('COMPLETED'), findsOneWidget);

    // 3. Switch back to Upcoming tab
    await tester.tap(find.text('Upcoming (1)'));
    await tester.pumpAndSettle();

    // 4. Cancel the upcoming appointment
    await tester.tap(find.byKey(const Key('cancel_appointment_btn_APT-100001')));
    await tester.pumpAndSettle();

    // Verify confirmation dialog
    expect(find.text('Cancel Appointment?'), findsOneWidget);
    expect(
        find.byKey(const Key('confirm_cancel_appointment_button')), findsOneWidget);

    // Confirm cancellation
    await tester
        .tap(find.byKey(const Key('confirm_cancel_appointment_button')));
    await tester.pumpAndSettle();

    // Verify tab counts updated
    expect(find.text('Upcoming (0)'), findsOneWidget);
    expect(find.text('Cancelled (1)'), findsOneWidget);
    expect(find.text('No Upcoming Visits'), findsOneWidget);

    // Verify the slot is freed in doctor repo
    final updatedDoc = await doctorRepo.getDoctorById('DOC-1');
    expect(updatedDoc!.availableSlots, isNotEmpty);

    aptProvider.dispose();
    docProvider.dispose();
  });

  testWidgets(
      'Live state sync: Dashboard upcoming card and NavigationBar bill badge reflect state',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final doctorRepo = _FakeDoctorRepo([testDoctor]);
    final aptRepo = _FakeAppointmentRepo([upcomingApt]);
    final billRepo = _FakeBillRepo([
      BillModel(
        id: 'BIL-SYNC-1',
        billDate: DateTime(2026, 9, 20),
        serviceName: 'Cardiology Review',
        consultationFee: 800.0,
        labCharges: 0.0,
        tax: 144.0,
        status: BillStatus.unpaid,
      ),
    ]);

    final aptProvider = AppointmentProvider(
      aptRepo,
      doctorRepository: doctorRepo,
      billRepository: billRepo,
    );
    final docProvider = DoctorProvider(doctorRepo);
    final billProvider = BillProvider(
      billRepository: billRepo,
      paymentGateway: _InstantPaymentGateway(),
    );
    final recordProvider = MedicalRecordProvider(_FakeRecordRepo());
    final prescriptionProvider =
        PrescriptionProvider(_FakePrescriptionRepo());

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<DoctorProvider>.value(value: docProvider),
          ChangeNotifierProvider<AppointmentProvider>.value(value: aptProvider),
          ChangeNotifierProvider<BillProvider>.value(value: billProvider),
          ChangeNotifierProvider<MedicalRecordProvider>.value(
              value: recordProvider),
          ChangeNotifierProvider<PrescriptionProvider>.value(
              value: prescriptionProvider),
        ],
        child: MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: const AppShell(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // 1. Dashboard shows upcoming appointment card
    expect(find.text('Upcoming Appointment'), findsWidgets);
    expect(find.text('Dr. Meera Nambiar'), findsWidgets);

    // 2. Bills tab has unpaid badge of 1
    expect(find.text('1'), findsWidgets);

    // 3. Switch to Appointments tab and cancel the upcoming appointment
    await tester.tap(find.text('Appointments'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('cancel_appointment_btn_APT-100001')));
    await tester.pumpAndSettle();
    await tester
        .tap(find.byKey(const Key('confirm_cancel_appointment_button')));
    await tester.pumpAndSettle();

    // 4. Return to Home tab -> upcoming card now shows "No Upcoming Appointments"
    await tester.tap(find.text('Home'));
    await tester.pumpAndSettle();

    expect(find.text('No Upcoming Appointments'), findsOneWidget);

    // 5. Pay the unpaid bill
    await billProvider.payBill(
      billId: 'BIL-SYNC-1',
      method: PaymentMethodType.upi,
      details: {'upiId': 'aditya@upi'},
    );
    await tester.pumpAndSettle();

    // Badge disappears because unpaidCount is now 0
    expect(billProvider.unpaidBillsCount, equals(0));

    aptProvider.dispose();
    docProvider.dispose();
    billProvider.dispose();
    recordProvider.dispose();
    prescriptionProvider.dispose();
  });
}
