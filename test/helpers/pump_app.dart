import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/core/theme/app_theme.dart';
import 'package:hospital_connect/providers/providers.dart';
import 'package:hospital_connect/routes/app_routes.dart';
import 'package:hospital_connect/services/booking_coordinator.dart';
import 'package:hospital_connect/services/mock/mock_services.dart';
import 'package:hospital_connect/services/repositories/repositories.dart';
import 'package:provider/provider.dart';

/// Test helper providing standard dependencies and providers for widget tests.
Future<void> pumpHospitalApp(
  WidgetTester tester, {
  Widget? home,
  String? initialRoute,
  MockDataService? mockDataService,
  DoctorRepository? doctorRepository,
  AppointmentRepository? appointmentRepository,
  MedicalRecordRepository? medicalRecordRepository,
  PrescriptionRepository? prescriptionRepository,
  BillRepository? billRepository,
  PaymentGateway? paymentGateway,
  DoctorProvider? doctorProvider,
  AppointmentProvider? appointmentProvider,
  MedicalRecordProvider? medicalRecordProvider,
  PrescriptionProvider? prescriptionProvider,
  BillProvider? billProvider,
  BookingCoordinator? bookingCoordinator,
}) async {
  final mockData = mockDataService ?? MockDataService();
  final dRepo = doctorRepository ?? MockDoctorRepository(mockData);
  final aRepo = appointmentRepository ?? MockAppointmentRepository(mockData);
  final mRepo =
      medicalRecordRepository ?? MockMedicalRecordRepository(mockData);
  final pRepo =
      prescriptionRepository ?? MockPrescriptionRepository(mockData);
  final bRepo = billRepository ?? MockBillRepository(mockData);
  final pGateway = paymentGateway ?? MockPaymentGateway();

  final dProvider = doctorProvider ?? DoctorProvider(dRepo);
  final aProvider = appointmentProvider ??
      AppointmentProvider(
        aRepo,
        doctorRepository: dRepo,
        billRepository: bRepo,
      );
  final mProvider = medicalRecordProvider ?? MedicalRecordProvider(mRepo);
  final rxProvider = prescriptionProvider ?? PrescriptionProvider(pRepo);
  final billProv = billProvider ??
      BillProvider(
        billRepository: bRepo,
        paymentGateway: pGateway,
      );
  final coordinator = bookingCoordinator ??
      BookingCoordinator(
        appointmentProvider: aProvider,
        doctorProvider: dProvider,
        billProvider: billProv,
      );

  final Widget appWidget;
  if (home != null) {
    appWidget = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(useGoogleFonts: false),
      home: home,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  } else {
    appWidget = MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(useGoogleFonts: false),
      initialRoute: initialRoute ?? AppRoutes.shell,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }

  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<DoctorProvider>.value(value: dProvider),
        ChangeNotifierProvider<AppointmentProvider>.value(value: aProvider),
        ChangeNotifierProvider<MedicalRecordProvider>.value(value: mProvider),
        ChangeNotifierProvider<PrescriptionProvider>.value(value: rxProvider),
        ChangeNotifierProvider<BillProvider>.value(value: billProv),
        ChangeNotifierProvider<BookingCoordinator>.value(value: coordinator),
      ],
      child: appWidget,
    ),
  );
  await tester.pump();
}
