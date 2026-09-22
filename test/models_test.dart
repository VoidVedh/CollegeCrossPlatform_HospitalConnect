import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/models/models.dart';

void main() {
  group('BillModel tests', () {
    test('totalAmount is dynamically computed as sum of fee, lab and tax', () {
      final BillModel bill = BillModel(
        id: 'BILL-001',
        billDate: DateTime(2026, 9, 29),
        serviceName: 'Cardiology Consultation',
        consultationFee: 800.0,
        labCharges: 450.0,
        tax: 62.5,
        status: BillStatus.unpaid,
      );

      expect(bill.totalAmount, equals(1312.5));
    });

    test('copyWith properly updates status, payment method and timestamp', () {
      final BillModel bill = BillModel(
        id: 'BILL-002',
        billDate: DateTime(2026, 9, 29),
        serviceName: 'General Consultation',
        consultationFee: 500.0,
        labCharges: 0.0,
        tax: 25.0,
        status: BillStatus.pending,
      );

      final paidTime = DateTime(2026, 9, 29, 14, 30);
      final updatedBill = bill.copyWith(
        status: BillStatus.paid,
        paymentMethod: PaymentMethodType.upi,
        paidAt: paidTime,
      );

      expect(updatedBill.status, equals(BillStatus.paid));
      expect(updatedBill.paymentMethod, equals(PaymentMethodType.upi));
      expect(updatedBill.paidAt, equals(paidTime));
      expect(updatedBill.totalAmount, equals(525.0));
    });
  });

  group('AppointmentModel tests', () {
    test('AppointmentModel stores and updates fields correctly', () {
      final appointment = AppointmentModel(
        id: 'APT-123456',
        doctorId: 'DOC-01',
        doctorName: 'Dr. Ananya Sharma',
        doctorSpecialty: 'Cardiology',
        patientName: 'Rahul Verma',
        patientAge: 28,
        patientPhone: '9876543210',
        appointmentDate: DateTime(2026, 10, 1),
        timeSlot: '10:00 AM',
        status: AppointmentStatus.upcoming,
        symptomsNote: 'Mild chest discomfort after running',
      );

      expect(appointment.id, equals('APT-123456'));
      expect(appointment.status, equals(AppointmentStatus.upcoming));

      final cancelled = appointment.copyWith(status: AppointmentStatus.cancelled);
      expect(cancelled.status, equals(AppointmentStatus.cancelled));
      expect(cancelled.patientName, equals('Rahul Verma'));
    });
  });

  group('DoctorModel tests', () {
    test('DoctorModel stores slots and reviews', () {
      final doctor = DoctorModel(
        id: 'DOC-01',
        name: 'Dr. Ananya Sharma',
        specialty: 'Cardiology',
        rating: 4.9,
        experienceYears: 12,
        hospitalName: 'Apollo Speciality Hospital',
        clinicAddress: 'Bannerghatta Road, Bengaluru',
        consultationFee: 800.0,
        availableSlots: [
          DateTime(2026, 10, 1, 10, 0),
          DateTime(2026, 10, 1, 11, 0),
        ],
        about: 'Senior interventional cardiologist.',
        reviews: [
          ReviewModel(
            id: 'REV-01',
            authorName: 'Suresh Kumar',
            rating: 5.0,
            comment: 'Very thorough diagnosis and calm demeanor.',
            date: DateTime(2026, 9, 15),
          ),
        ],
      );

      expect(doctor.reviews.length, equals(1));
      expect(doctor.availableSlots.length, equals(2));
      expect(doctor.consultationFee, equals(800.0));
    });
  });
}
