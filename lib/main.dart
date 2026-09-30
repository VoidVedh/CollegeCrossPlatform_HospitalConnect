import 'package:flutter/material.dart';
import 'package:hospital_connect/app.dart';
import 'package:hospital_connect/providers/providers.dart';
import 'package:hospital_connect/services/booking_coordinator.dart';
import 'package:hospital_connect/services/mock/mock_services.dart';
import 'package:hospital_connect/services/repositories/repositories.dart';
import 'package:provider/provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Instantiate data source and mock repository implementations
  final mockDataService = MockDataService();
  final DoctorRepository doctorRepository =
      MockDoctorRepository(mockDataService);
  final AppointmentRepository appointmentRepository =
      MockAppointmentRepository(mockDataService);
  final MedicalRecordRepository medicalRecordRepository =
      MockMedicalRecordRepository(mockDataService);
  final PrescriptionRepository prescriptionRepository =
      MockPrescriptionRepository(mockDataService);
  final BillRepository billRepository = MockBillRepository(mockDataService);
  final PaymentGateway paymentGateway = MockPaymentGateway();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<PatientProfileProvider>(
          create: (_) => PatientProfileProvider(),
        ),
        ChangeNotifierProvider<DoctorProvider>(
          create: (_) => DoctorProvider(doctorRepository),
        ),
        ChangeNotifierProvider<AppointmentProvider>(
          create: (_) => AppointmentProvider(
            appointmentRepository,
            doctorRepository: doctorRepository,
            billRepository: billRepository,
          ),
        ),
        ChangeNotifierProvider<MedicalRecordProvider>(
          create: (_) => MedicalRecordProvider(medicalRecordRepository),
        ),
        ChangeNotifierProvider<PrescriptionProvider>(
          create: (_) => PrescriptionProvider(prescriptionRepository),
        ),
        ChangeNotifierProvider<BillProvider>(
          create: (_) => BillProvider(
            billRepository: billRepository,
            paymentGateway: paymentGateway,
          ),
        ),
        ChangeNotifierProxyProvider3<AppointmentProvider, DoctorProvider,
            BillProvider, BookingCoordinator>(
          create: (ctx) => BookingCoordinator(
            appointmentProvider: ctx.read<AppointmentProvider>(),
            doctorProvider: ctx.read<DoctorProvider>(),
            billProvider: ctx.read<BillProvider>(),
          ),
          update: (_, appointmentProvider, doctorProvider, billProvider,
                  coordinator) =>
              (coordinator ??
                  BookingCoordinator(
                    appointmentProvider: appointmentProvider,
                    doctorProvider: doctorProvider,
                    billProvider: billProvider,
                  ))
                ..update(
                  appointmentProvider: appointmentProvider,
                  doctorProvider: doctorProvider,
                  billProvider: billProvider,
                ),
        ),
      ],
      child: const HospitalConnectApp(),
    ),
  );
}
