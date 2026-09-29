import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/core/theme/app_theme.dart';
import 'package:hospital_connect/core/utils/validators.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/providers.dart';
import 'package:hospital_connect/screens/app_shell.dart';
import 'package:hospital_connect/screens/billing/billing_screen.dart';
import 'package:hospital_connect/screens/doctors/doctor_detail_screen.dart';
import 'package:hospital_connect/services/repositories/repositories.dart';
import 'package:provider/provider.dart';

class _AuditDoctorRepo implements DoctorRepository {
  @override
  Future<List<DoctorModel>> getDoctors() async => [
        DoctorModel(
          id: 'DOC-AUDIT',
          name: 'Dr. Anand Raman',
          specialty: 'Neurology',
          rating: 4.8,
          experienceYears: 16,
          hospitalName: 'Apollo Hospital',
          clinicAddress: 'MG Road, Bangalore',
          consultationFee: 950.0,
          availableSlots: [DateTime(2026, 10, 1, 10, 0)],
          about: 'Senior consultant neurologist specializing in neuro-genetics.',
          reviews: const [],
        ),
      ];

  @override
  Future<DoctorModel?> getDoctorById(String id) async => (await getDoctors()).first;

  @override
  Future<List<DoctorModel>> searchDoctors(String query, {String? specialty}) async =>
      getDoctors();

  @override
  Future<bool> markSlotAvailability({
    required String doctorId,
    required DateTime slot,
    required bool isAvailable,
  }) async =>
      true;
}

class _AuditAppointmentRepo implements AppointmentRepository {
  @override
  Future<List<AppointmentModel>> getAppointments() async => [];
  @override
  Future<AppointmentModel?> getAppointmentById(String id) async => null;
  @override
  Future<AppointmentModel> bookAppointment(AppointmentModel appointment) async =>
      appointment;
  @override
  Future<AppointmentModel> cancelAppointment(String id) async =>
      throw UnimplementedError();
}

class _AuditBillRepo implements BillRepository {
  @override
  Future<List<BillModel>> getBills() async => [
        BillModel(
          id: 'BIL-AUDIT-1',
          billDate: DateTime(2026, 9, 28),
          serviceName: 'Neurology Consultation & EEG Scan',
          consultationFee: 950.0,
          labCharges: 450.0,
          tax: 252.0,
          status: BillStatus.unpaid,
        ),
      ];

  @override
  Future<BillModel?> getBillById(String id) async => (await getBills()).first;
  @override
  Future<BillModel> addBill(BillModel bill) async => bill;
  @override
  Future<BillModel> updateBillStatus({
    required String billId,
    required BillStatus status,
    PaymentMethodType? paymentMethod,
    DateTime? paidAt,
  }) async =>
      (await getBills()).first.copyWith(status: status);
}

class _AuditPaymentGateway implements PaymentGateway {
  @override
  Future<PaymentResult> processPayment({
    required String billId,
    required double amount,
    required PaymentMethodType method,
    required Map<String, String> details,
  }) async =>
      const PaymentResult(
        isSuccess: true,
        transactionId: 'TXN-AUDIT-100',
        message: 'Success',
      );
}

class _AuditRecordRepo implements MedicalRecordRepository {
  @override
  Future<List<MedicalRecordModel>> getMedicalRecords() async => [];
  @override
  Future<MedicalRecordModel?> getRecordById(String id) async => null;
}

class _AuditPrescriptionRepo implements PrescriptionRepository {
  @override
  Future<List<PrescriptionModel>> getPrescriptions() async => [];
  @override
  Future<PrescriptionModel?> getPrescriptionById(String id) async => null;
}

void main() {
  group('Accessibility & Resilience Audit Tests', () {
    test('Validators enforce strict input hygiene', () {
      expect(AppValidators.validateName('A'), isNotNull);
      expect(AppValidators.validateName('Aditya Sharma'), isNull);

      expect(AppValidators.validateAge('0'), isNotNull);
      expect(AppValidators.validateAge('125'), isNotNull);
      expect(AppValidators.validateAge('28'), isNull);

      expect(AppValidators.validatePhone('1234567890'), isNotNull);
      expect(AppValidators.validatePhone('9876543210'), isNull);

      expect(AppValidators.validateSymptoms('Headache'), isNotNull); // < 10
      expect(
          AppValidators.validateSymptoms('Severe migraine with light sensitivity'),
          isNull);

      expect(AppValidators.validateUpiId('invalidupi'), isNotNull);
      expect(AppValidators.validateUpiId('patient@okhdfcbank'), isNull);

      expect(AppValidators.validateCardNumber('1234'), isNotNull);
      expect(AppValidators.validateCardNumber('4532890123456789'), isNull);

      expect(AppValidators.validateCardExpiry('13/28'), isNotNull);
      expect(AppValidators.validateCardExpiry('08/20'), isNotNull); // Expired
      expect(AppValidators.validateCardExpiry('08/28'), isNull);

      expect(AppValidators.validateCvv('12'), isNotNull);
      expect(AppValidators.validateCvv('123'), isNull);
    });

    testWidgets('App shell renders without overflow on 1.3x text scale',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final docRepo = _AuditDoctorRepo();
      final aptRepo = _AuditAppointmentRepo();
      final billRepo = _AuditBillRepo();
      final recordRepo = _AuditRecordRepo();
      final prescriptionRepo = _AuditPrescriptionRepo();
      final gateway = _AuditPaymentGateway();

      final docProvider = DoctorProvider(docRepo);
      final aptProvider = AppointmentProvider(aptRepo);
      final billProvider =
          BillProvider(billRepository: billRepo, paymentGateway: gateway);
      final recordProvider = MedicalRecordProvider(recordRepo);
      final prescriptionProvider = PrescriptionProvider(prescriptionRepo);

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
            builder: (context, child) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: const TextScaler.linear(1.3),
                ),
                child: child!,
              );
            },
            home: const AppShell(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify home dashboard renders without any exceptions
      expect(find.text('Hello, Aditya 👋'), findsOneWidget);
      expect(find.text('Find by Specialty'), findsOneWidget);

      docProvider.dispose();
      aptProvider.dispose();
      billProvider.dispose();
      recordProvider.dispose();
      prescriptionProvider.dispose();
    });

    testWidgets('Tablet layout check (1024x1366) renders centered constraints',
        (tester) async {
      tester.view.physicalSize = const Size(1024, 1366);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final billRepo = _AuditBillRepo();
      final gateway = _AuditPaymentGateway();
      final billProvider =
          BillProvider(billRepository: billRepo, paymentGateway: gateway);

      await tester.pumpWidget(
        ChangeNotifierProvider<BillProvider>.value(
          value: billProvider,
          child: MaterialApp(
            theme: AppTheme.light(useGoogleFonts: false),
            home: const BillingScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Bills & Payments'), findsOneWidget);
      expect(find.text('OUTSTANDING DUES'), findsOneWidget);
      expect(find.text('BIL-AUDIT-1'), findsOneWidget);

      billProvider.dispose();
    });

    testWidgets('DoctorDetailScreen renders metrics, bio, and sticky booking bar',
        (tester) async {
      tester.view.physicalSize = const Size(800, 1600);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });

      final doctor = (await _AuditDoctorRepo().getDoctors()).first;

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: DoctorDetailScreen(doctor: doctor),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Dr. Anand Raman'), findsOneWidget);
      expect(find.text('Neurology'), findsOneWidget);
      expect(find.text('16+ Yrs'), findsOneWidget);
      expect(find.text('Book Appointment'), findsOneWidget);
    });
  });
}
