import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/providers.dart';
import 'package:hospital_connect/services/mock/mock_services.dart';

void main() {
  group('End-to-End HospitalConnect Workflow Integration Tests', () {
    late MockDataService dataService;
    late MockDoctorRepository doctorRepo;
    late MockAppointmentRepository appointmentRepo;
    late MockBillRepository billRepo;
    late MockPaymentGateway paymentGateway;
    late AppointmentProvider appointmentProvider;
    late BillProvider billProvider;

    setUp(() {
      dataService = MockDataService();
      doctorRepo = MockDoctorRepository(dataService);
      appointmentRepo = MockAppointmentRepository(dataService);
      billRepo = MockBillRepository(dataService);
      paymentGateway = MockPaymentGateway();

      appointmentProvider = AppointmentProvider(
        appointmentRepo,
        doctorRepository: doctorRepo,
        billRepository: billRepo,
      );

      billProvider = BillProvider(
        billRepository: billRepo,
        paymentGateway: paymentGateway,
      );
    });

    test('Full End-to-End Patient Journey: Discover -> Book -> Auto-Invoice -> Pay', () async {
      await appointmentProvider.loadAppointments();
      await billProvider.loadBills();

      // 1. Doctor Discovery
      final doctors = await doctorRepo.getDoctors();
      expect(doctors.isNotEmpty, isTrue);
      final cardiologist = doctors.firstWhere((d) => d.specialty.toLowerCase().contains('cardio'));
      expect(cardiologist.name, isNotEmpty);
      expect(cardiologist.consultationFee, greaterThan(0));

      // 2. Book an Appointment
      final bookingDate = DateTime.now().add(const Duration(days: 2));
      const bookingSlot = '10:00 AM';
      final initialUpcomingCount = appointmentProvider.upcomingAppointments.length;
      final initialBillsCount = billProvider.bills.length;

      final bookedAppointment = await appointmentProvider.bookAppointment(
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

      // Reload Bills and verify auto-generated invoice
      await billProvider.loadBills();
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

      // 4. Verify bill is settled
      final settledBill = billProvider.getBillById(generatedBill.id);
      expect(settledBill, isNotNull);
      expect(settledBill!.status, equals(BillStatus.paid));
      expect(settledBill.paymentMethod, equals(PaymentMethodType.upi));
      expect(settledBill.paidAt, isNotNull);
    });

    test('Cancellation flow frees the appointment and updates state', () async {
      await appointmentProvider.loadAppointments();
      final upcoming = appointmentProvider.upcomingAppointments;
      expect(upcoming.isNotEmpty, isTrue);

      final toCancel = upcoming.first;
      final cancelled = await appointmentProvider.cancelAppointment(toCancel.id);

      expect(cancelled.status, equals(AppointmentStatus.cancelled));
      expect(
        appointmentProvider.upcomingAppointments.any((a) => a.id == toCancel.id),
        isFalse,
      );
    });
  });
}
