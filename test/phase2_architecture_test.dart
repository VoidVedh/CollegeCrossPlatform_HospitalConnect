import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/core/errors/app_exceptions.dart';
import 'package:hospital_connect/core/utils/safe_notifier.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/providers.dart';
import 'package:hospital_connect/services/booking_coordinator.dart';
import 'package:hospital_connect/services/mock/mock_services.dart';

void main() {
  group('Phase 2 Architecture & Correctness Tests', () {
    test('SafeNotifier prevents notifyListeners call after dispose without throwing', () {
      final notifier = _TestSafeNotifier();
      int listenerCalls = 0;
      notifier.addListener(() {
        listenerCalls++;
      });

      notifier.doNotify();
      expect(listenerCalls, 1);

      notifier.dispose();
      expect(notifier.isDisposed, true);

      // Calling doNotify after dispose must not throw and must not invoke listener
      expect(() => notifier.doNotify(), returnsNormally);
      expect(listenerCalls, 1);
    });

    test('Domain Models: Real equality and fromJson/toJson serialization', () {
      final now = DateTime(2026, 9, 30, 10, 0);

      // 1. AppointmentModel
      final apt1 = AppointmentModel(
        id: 'APT-001',
        doctorId: 'DOC-01',
        doctorName: 'Dr. Sharma',
        doctorSpecialty: 'Cardiology',
        patientName: 'John Doe',
        patientAge: 35,
        patientPhone: '9876543210',
        appointmentDate: now,
        timeSlot: '10:00 AM',
        status: AppointmentStatus.upcoming,
        symptomsNote: 'Routine checkup',
      );
      final apt2 = AppointmentModel.fromJson(apt1.toJson());
      expect(apt1, equals(apt2));
      expect(apt1.hashCode, equals(apt2.hashCode));

      final aptDifferent = apt1.copyWith(patientAge: 36);
      expect(apt1 == aptDifferent, isFalse);

      // 2. BillModel
      final bill1 = BillModel(
        id: 'BILL-001',
        billDate: now,
        serviceName: 'Consultation - Dr. Sharma',
        consultationFee: 800.0,
        labCharges: 0.0,
        tax: 144.0,
        status: BillStatus.unpaid,
        appointmentId: 'APT-001',
      );
      final bill2 = BillModel.fromJson(bill1.toJson());
      expect(bill1, equals(bill2));
      expect(bill1.hashCode, equals(bill2.hashCode));

      final billDifferent = bill1.copyWith(tax: 150.0);
      expect(bill1 == billDifferent, isFalse);

      // 3. DoctorModel with nested reviews and slots
      final doc1 = DoctorModel(
        id: 'DOC-01',
        name: 'Dr. Sharma',
        specialty: 'Cardiology',
        rating: 4.9,
        experienceYears: 14,
        hospitalName: 'Apollo',
        clinicAddress: 'Bannerghatta Rd',
        consultationFee: 800.0,
        availableSlots: [now],
        about: 'Expert cardiologist',
        reviews: [
          ReviewModel(
            id: 'REV-01',
            authorName: 'Alice',
            rating: 5.0,
            comment: 'Great',
            date: now,
          ),
        ],
      );
      final doc2 = DoctorModel.fromJson(doc1.toJson());
      expect(doc1, equals(doc2));
      expect(doc1.hashCode, equals(doc2.hashCode));

      final docDifferent = doc1.copyWith(experienceYears: 15);
      expect(doc1 == docDifferent, isFalse);

      // 4. PrescriptionModel with medications
      final rx1 = PrescriptionModel(
        id: 'RX-001',
        doctorName: 'Dr. Sharma',
        issueDate: now,
        diagnosis: 'Hypertension',
        medications: const [
          MedicationModel(
            name: 'Amlodipine',
            dosage: '5mg',
            frequency: 'Once daily',
            duration: '30 days',
          ),
        ],
        instructions: 'Take after breakfast',
      );
      final rx2 = PrescriptionModel.fromJson(rx1.toJson());
      expect(rx1, equals(rx2));
      expect(rx1.hashCode, equals(rx2.hashCode));

      final rxDifferent = rx1.copyWith(diagnosis: 'Mild Hypertension');
      expect(rx1 == rxDifferent, isFalse);

      // 5. MedicalRecordModel with attachments
      final rec1 = MedicalRecordModel(
        id: 'REC-001',
        diagnosis: 'Chest Pain',
        doctorName: 'Dr. Sharma',
        visitDate: now,
        hospitalName: 'Apollo',
        summary: 'Normal ECG',
        attachments: const [
          RecordAttachmentModel(fileName: 'ecg.pdf', fileType: 'pdf'),
        ],
      );
      final rec2 = MedicalRecordModel.fromJson(rec1.toJson());
      expect(rec1, equals(rec2));
      expect(rec1.hashCode, equals(rec2.hashCode));

      final recDifferent = rec1.copyWith(summary: 'ECG slightly irregular');
      expect(rec1 == recDifferent, isFalse);
    });

    test('BookingCoordinator: atomically books and syncs doctor slots and bills', () async {
      final mockData = MockDataService();
      final doctorRepo = MockDoctorRepository(mockData);
      final appointmentRepo = MockAppointmentRepository(mockData);
      final billRepo = MockBillRepository(mockData);
      final paymentGateway = MockPaymentGateway();

      final doctorProvider = DoctorProvider(doctorRepo);
      final billProvider = BillProvider(
        billRepository: billRepo,
        paymentGateway: paymentGateway,
      );
      final appointmentProvider = AppointmentProvider(
        appointmentRepo,
        doctorRepository: doctorRepo,
        billRepository: billRepo,
      );

      await Future.wait<void>([
        doctorProvider.loadDoctors(),
        billProvider.loadBills(),
        appointmentProvider.loadAppointments(),
      ]);

      final coordinator = BookingCoordinator(
        appointmentProvider: appointmentProvider,
        doctorProvider: doctorProvider,
        billProvider: billProvider,
      );

      final doctor = doctorProvider.doctors.first;
      final targetDate = DateTime.now().add(const Duration(days: 1));
      const targetSlot = '10:30 AM';
      final initialBillCount = billProvider.bills.length;

      // Book via coordinator
      final booked = await coordinator.bookAppointment(
        doctorId: doctor.id,
        doctorName: doctor.name,
        doctorSpecialty: doctor.specialty,
        patientName: 'Test Patient',
        patientAge: 40,
        patientPhone: '9876543210',
        appointmentDate: targetDate,
        timeSlot: targetSlot,
        symptomsNote: 'Coordinator test',
        consultationFee: doctor.consultationFee,
      );

      // Doctor slots and bills must be synced immediately without manual UI calls
      expect(appointmentProvider.appointments.any((a) => a.id == booked.id), isTrue);
      expect(billProvider.bills.length, initialBillCount + 1);
      final linkedBill = billProvider.bills.firstWhere((b) => b.appointmentId == booked.id);
      expect(linkedBill.status, BillStatus.pending);

      // Cancel via coordinator
      await coordinator.cancelAppointment(booked.id);

      // Verification: appointment cancelled, bill voided/cancelled, doctor slot restored
      final cancelledApt = appointmentProvider.appointments.firstWhere((a) => a.id == booked.id);
      expect(cancelledApt.status, AppointmentStatus.cancelled);
      final updatedBill = billProvider.bills.firstWhere((b) => b.appointmentId == booked.id);
      expect(updatedBill.status, BillStatus.cancelled);
    });

    test('Honest Repositories throw NotFoundException on non-existent entities', () async {
      final mockData = MockDataService();
      final appointmentRepo = MockAppointmentRepository(mockData);
      final billRepo = MockBillRepository(mockData);

      expect(
        () => appointmentRepo.cancelAppointment('NON-EXISTENT-ID'),
        throwsA(isA<NotFoundException>()),
      );

      expect(
        () => billRepo.updateBillStatus(
          billId: 'NON-EXISTENT-BILL',
          status: BillStatus.paid,
        ),
        throwsA(isA<NotFoundException>()),
      );
    });
  });
}

class _TestSafeNotifier extends ChangeNotifier with SafeNotifier {
  void doNotify() {
    notifyListeners();
  }
}
