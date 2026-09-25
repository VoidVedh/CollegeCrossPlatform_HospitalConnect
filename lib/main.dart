import 'package:flutter/material.dart';
import 'package:hospital_connect/app.dart';
import 'package:hospital_connect/providers/providers.dart';
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
      ],
      child: const HospitalConnectApp(),
    ),
  );
}
