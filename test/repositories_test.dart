import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/services/mock/mock_services.dart';

void main() {
  group('Mock Repository Tests', () {
    late MockDataService dataService;
    late MockDoctorRepository doctorRepo;
    late MockAppointmentRepository appointmentRepo;
    late MockBillRepository billRepo;
    late MockPaymentGateway paymentGateway;

    setUp(() {
      dataService = MockDataService();
      doctorRepo = MockDoctorRepository(dataService);
      appointmentRepo = MockAppointmentRepository(dataService);
      billRepo = MockBillRepository(dataService);
      paymentGateway = MockPaymentGateway();
    });

    test('Doctor repository returns 8+ doctors across specialties', () async {
      final doctors = await doctorRepo.getDoctors();
      expect(doctors.length, greaterThanOrEqualTo(8));

      final cardios = await doctorRepo.searchDoctors('', specialty: 'Cardiology');
      expect(cardios.isNotEmpty, isTrue);
      expect(cardios.every((d) => d.specialty == 'Cardiology'), isTrue);

      final searchResults = await doctorRepo.searchDoctors('Sharma');
      expect(searchResults.any((d) => d.name.contains('Sharma')), isTrue);
    });

    test('Appointment repository retrieves existing and books new appointment', () async {
      final appointments = await appointmentRepo.getAppointments();
      expect(appointments.length, equals(1));
      expect(appointments.first.status, equals(AppointmentStatus.upcoming));

      final newApt = AppointmentModel(
        id: 'APT-999999',
        doctorId: 'DOC-01',
        doctorName: 'Dr. Ananya Sharma',
        doctorSpecialty: 'Cardiology',
        patientName: 'Test Patient',
        patientAge: 32,
        patientPhone: '9876543210',
        appointmentDate: DateTime.now().add(const Duration(days: 2)),
        timeSlot: '11:00 AM',
        status: AppointmentStatus.upcoming,
        symptomsNote: 'Routine checkup for blood pressure',
      );

      final booked = await appointmentRepo.bookAppointment(newApt);
      expect(booked.id, equals('APT-999999'));

      final allAfterBook = await appointmentRepo.getAppointments();
      expect(allAfterBook.length, equals(2));

      final cancelled = await appointmentRepo.cancelAppointment('APT-999999');
      expect(cancelled.status, equals(AppointmentStatus.cancelled));
    });

    test('Bill repository manages invoices and updates paid status', () async {
      final bills = await billRepo.getBills();
      expect(bills.length, greaterThanOrEqualTo(4));

      final unpaid = bills.firstWhere((b) => b.status == BillStatus.unpaid);
      final updated = await billRepo.updateBillStatus(
        billId: unpaid.id,
        status: BillStatus.paid,
        paymentMethod: PaymentMethodType.upi,
        paidAt: DateTime.now(),
      );

      expect(updated.status, equals(BillStatus.paid));
      expect(updated.paymentMethod, equals(PaymentMethodType.upi));
    });

    test('Payment gateway validates payment details and returns transaction ID', () async {
      final successResult = await paymentGateway.processPayment(
        billId: 'BILL-101',
        amount: 1312.5,
        method: PaymentMethodType.upi,
        details: {'upiId': 'patient@upi'},
      );
      expect(successResult.isSuccess, isTrue);
      expect(successResult.transactionId.startsWith('TXN-'), isTrue);

      final failedResult = await paymentGateway.processPayment(
        billId: 'BILL-101',
        amount: 1312.5,
        method: PaymentMethodType.upi,
        details: {'upiId': 'invalidupi'},
      );
      expect(failedResult.isSuccess, isFalse);
    });
  });
}
