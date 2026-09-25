import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_theme.dart';
import 'package:hospital_connect/providers/providers.dart';
import 'package:hospital_connect/screens/app_shell.dart';
import 'package:hospital_connect/screens/appointments/appointments_screen.dart';
import 'package:hospital_connect/screens/billing/billing_screen.dart';
import 'package:hospital_connect/screens/dashboard/dashboard_screen.dart';
import 'package:hospital_connect/screens/doctors/doctors_screen.dart';
import 'package:hospital_connect/screens/records/records_screen.dart';
import 'package:hospital_connect/services/mock/mock_services.dart';
import 'package:provider/provider.dart';

/// Root application widget for HospitalConnect.
class HospitalConnectApp extends StatefulWidget {
  const HospitalConnectApp({
    super.key,
    this.useGoogleFonts = true,
  });

  /// Set to false in widget tests to avoid runtime font fetching.
  final bool useGoogleFonts;

  @override
  State<HospitalConnectApp> createState() => _HospitalConnectAppState();
}

class _HospitalConnectAppState extends State<HospitalConnectApp> {
  late final MockDataService _fallbackMockData;
  late final DoctorProvider _fallbackDoctorProvider;
  late final AppointmentProvider _fallbackAppointmentProvider;
  late final MedicalRecordProvider _fallbackRecordProvider;
  late final PrescriptionProvider _fallbackPrescriptionProvider;
  late final BillProvider _fallbackBillProvider;

  @override
  void initState() {
    super.initState();
    _fallbackMockData = MockDataService();
    _fallbackDoctorProvider =
        DoctorProvider(MockDoctorRepository(_fallbackMockData));
    _fallbackAppointmentProvider = AppointmentProvider(
      MockAppointmentRepository(_fallbackMockData),
      doctorRepository: MockDoctorRepository(_fallbackMockData),
      billRepository: MockBillRepository(_fallbackMockData),
    );
    _fallbackRecordProvider =
        MedicalRecordProvider(MockMedicalRecordRepository(_fallbackMockData));
    _fallbackPrescriptionProvider =
        PrescriptionProvider(MockPrescriptionRepository(_fallbackMockData));
    _fallbackBillProvider = BillProvider(
      billRepository: MockBillRepository(_fallbackMockData),
      paymentGateway: MockPaymentGateway(),
    );
  }

  @override
  void dispose() {
    _fallbackDoctorProvider.dispose();
    _fallbackAppointmentProvider.dispose();
    _fallbackRecordProvider.dispose();
    _fallbackPrescriptionProvider.dispose();
    _fallbackBillProvider.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Widget app = MaterialApp(
      title: 'HospitalConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(useGoogleFonts: widget.useGoogleFonts),
      initialRoute: '/',
      routes: <String, WidgetBuilder>{
        '/': (_) => const AppShell(),
        '/dashboard': (_) => const DashboardScreen(),
        '/doctors': (_) => const DoctorsScreen(),
        '/appointments': (_) => const AppointmentsScreen(),
        '/records': (_) => const RecordsScreen(),
        '/billing': (_) => const BillingScreen(),
      },
    );

    // If an ancestor Provider is already supplied (e.g. from main.dart), use it directly.
    try {
      Provider.of<DoctorProvider>(context, listen: false);
      return app;
    } catch (_) {
      // In isolated widget tests, inject persistent stateful providers.
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<DoctorProvider>.value(
            value: _fallbackDoctorProvider,
          ),
          ChangeNotifierProvider<AppointmentProvider>.value(
            value: _fallbackAppointmentProvider,
          ),
          ChangeNotifierProvider<MedicalRecordProvider>.value(
            value: _fallbackRecordProvider,
          ),
          ChangeNotifierProvider<PrescriptionProvider>.value(
            value: _fallbackPrescriptionProvider,
          ),
          ChangeNotifierProvider<BillProvider>.value(
            value: _fallbackBillProvider,
          ),
        ],
        child: app,
      );
    }
  }
}
