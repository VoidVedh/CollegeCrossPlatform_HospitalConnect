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
class HospitalConnectApp extends StatelessWidget {
  const HospitalConnectApp({
    super.key,
    this.useGoogleFonts = true,
  });

  /// Set to false in widget tests to avoid runtime font fetching.
  final bool useGoogleFonts;

  @override
  Widget build(BuildContext context) {
    final Widget app = MaterialApp(
      title: 'HospitalConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(useGoogleFonts: useGoogleFonts),
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
      // In isolated widget tests, inject default mock providers so the tree resolves cleanly.
      final mockData = MockDataService();
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<DoctorProvider>(
            create: (_) => DoctorProvider(MockDoctorRepository(mockData)),
          ),
          ChangeNotifierProvider<AppointmentProvider>(
            create: (_) =>
                AppointmentProvider(MockAppointmentRepository(mockData)),
          ),
          ChangeNotifierProvider<MedicalRecordProvider>(
            create: (_) =>
                MedicalRecordProvider(MockMedicalRecordRepository(mockData)),
          ),
          ChangeNotifierProvider<PrescriptionProvider>(
            create: (_) =>
                PrescriptionProvider(MockPrescriptionRepository(mockData)),
          ),
          ChangeNotifierProvider<BillProvider>(
            create: (_) => BillProvider(
              billRepository: MockBillRepository(mockData),
              paymentGateway: MockPaymentGateway(),
            ),
          ),
        ],
        child: app,
      );
    }
  }
}
