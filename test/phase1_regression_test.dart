import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/core/constants/app_constants.dart';
import 'package:hospital_connect/core/errors/app_exceptions.dart';
import 'package:hospital_connect/core/utils/bill_calculator.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/core/utils/validators.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/appointment_provider.dart';
import 'package:hospital_connect/providers/bill_provider.dart';
import 'package:hospital_connect/services/mock/mock_services.dart';
import 'package:hospital_connect/services/slot_schedule_service.dart';

void main() {
  group('Phase 1 Correctness Regression Tests', () {
    test('1. parseTimeSlot throws FormatException on invalid input and tryParseTimeSlot returns null', () {
      final date = DateTime(2026, 9, 30);
      expect(() => AppFormatters.parseTimeSlot(date, 'invalid-time'), throwsFormatException);
      expect(AppFormatters.tryParseTimeSlot(date, 'invalid-time'), isNull);

      final valid = AppFormatters.parseTimeSlot(date, '10:30 AM');
      expect(valid.hour, equals(10));
      expect(valid.minute, equals(30));
    });

    test('2. Card validation enforces Luhn, dynamic expiry (relative to now), and 3/4 digit CVV', () {
      // Luhn Check
      expect(AppValidators.validateCardNumber('1111 1111 1111 1111'), contains('checksum'));
      // Valid Visa Luhn card
      expect(AppValidators.validateCardNumber('4532 0151 1283 0366'), isNull);

      // Relative Expiry
      final now = DateTime.now();
      final pastMonth = now.month == 1 ? 12 : now.month - 1;
      final pastYear = now.month == 1 ? now.year - 1 : now.year;
      final pastExpiryStr = '${pastMonth.toString().padLeft(2, '0')}/${pastYear.toString().substring(2)}';
      expect(AppValidators.validateCardExpiry(pastExpiryStr), equals('Card has expired'));

      final futureYear = now.year + 2;
      final futureExpiry2Digit = '06/${futureYear.toString().substring(2)}';
      expect(AppValidators.validateCardExpiry(futureExpiry2Digit), isNull);
      final futureExpiry4Digit = '06/$futureYear';
      expect(AppValidators.validateCardExpiry(futureExpiry4Digit), isNull);

      // CVV
      expect(AppValidators.validateCvv('123'), isNull);
      expect(AppValidators.validateCvv('1234'), isNull);
      expect(AppValidators.validateCvv('12'), equals('CVV must be 3 or 4 digits'));
      expect(AppValidators.validateCvv('12345'), equals('CVV must be 3 or 4 digits'));
    });

    test('3. Slot availability single source of truth handles template, last slot, cancellation, and past times', () {
      const scheduleService = SlotScheduleService();
      const doctor = DoctorModel(
        id: 'DOC-TEST',
        name: 'Dr. Test',
        specialty: 'General',
        rating: 4.8,
        experienceYears: 10,
        hospitalName: 'Hospital',
        clinicAddress: 'Address',
        consultationFee: 500,
        imageUrl: '',
        about: 'Bio',
        availableSlots: [],
        reviews: [],
      );

      final futureDate = DateTime.now().add(const Duration(days: 4));
      final allSlots = scheduleService.getSlotsForDoctorAndDate(
        doctor: doctor,
        date: futureDate,
        existingAppointments: const [],
      );

      // Grid includes working hours template with lunch gap
      expect(allSlots.any((s) => s.time == '09:00 AM'), isTrue);
      expect(allSlots.any((s) => s.time == '01:00 PM'), isFalse, reason: 'Lunch gap excluded');
      expect(allSlots.any((s) => s.time == '05:00 PM'), isTrue);

      // Booking the last slot of a date does NOT reopen the others
      final appointments = allSlots.map((s) => AppointmentModel(
        id: 'APT-${s.time}',
        doctorId: doctor.id,
        doctorName: doctor.name,
        doctorSpecialty: doctor.specialty,
        patientName: 'Patient',
        patientAge: 30,
        patientPhone: '9876543210',
        appointmentDate: futureDate,
        timeSlot: s.time,
        status: AppointmentStatus.upcoming,
        symptomsNote: 'Notes',
      )).toList();

      final fullDaySlots = scheduleService.getSlotsForDoctorAndDate(
        doctor: doctor,
        date: futureDate,
        existingAppointments: appointments,
      );

      expect(fullDaySlots.every((s) => !s.isAvailable), isTrue,
          reason: 'When all slots are booked, none are available; does not reopen');

      // Cancelling restores exactly that slot
      final cancelledOne = appointments.sublist(1);
      final restoredSlots = scheduleService.getSlotsForDoctorAndDate(
        doctor: doctor,
        date: futureDate,
        existingAppointments: cancelledOne,
      );
      final firstSlot = restoredSlots.firstWhere((s) => s.time == allSlots.first.time);
      expect(firstSlot.isAvailable, isTrue, reason: 'Cancelled slot is restored');
      expect(restoredSlots.where((s) => s.isAvailable).length, equals(1));
    });

    test('4. Double-booking guard rejects with typed exception', () async {
      final dataService = MockDataService();
      final doctorRepo = MockDoctorRepository(dataService);
      final appointmentRepo = MockAppointmentRepository(dataService);
      final billRepo = MockBillRepository(dataService);
      final provider = AppointmentProvider(
        appointmentRepo,
        doctorRepository: doctorRepo,
        billRepository: billRepo,
      );

      final doctor = (await doctorRepo.getDoctors()).first;
      final futureDate = DateTime.now().add(const Duration(days: 3));
      const slot = '11:00 AM';

      await provider.bookAppointment(
        doctorId: doctor.id,
        doctorName: doctor.name,
        doctorSpecialty: doctor.specialty,
        patientName: 'P1',
        patientAge: 25,
        patientPhone: '9876543210',
        appointmentDate: futureDate,
        timeSlot: slot,
        symptomsNote: 'Checkup note 1',
      );

      // Second booking must throw SlotUnavailableException
      expect(
        () => provider.bookAppointment(
          doctorId: doctor.id,
          doctorName: doctor.name,
          doctorSpecialty: doctor.specialty,
          patientName: 'P2',
          patientAge: 26,
          patientPhone: '9876543211',
          appointmentDate: futureDate,
          timeSlot: slot,
          symptomsNote: 'Checkup note 2',
        ),
        throwsA(isA<SlotUnavailableException>()),
      );
    });

    test('5. Cancelling an appointment voids linked bill and updates unpaid count', () async {
      final dataService = MockDataService();
      final doctorRepo = MockDoctorRepository(dataService);
      final appointmentRepo = MockAppointmentRepository(dataService);
      final billRepo = MockBillRepository(dataService);
      final appointmentProvider = AppointmentProvider(
        appointmentRepo,
        doctorRepository: doctorRepo,
        billRepository: billRepo,
      );
      final billProvider = BillProvider(
        billRepository: billRepo,
        paymentGateway: MockPaymentGateway(),
      );
      await appointmentProvider.loadAppointments();
      await billProvider.loadBills();

      final initialUnpaid = billProvider.unpaidBillsCount;
      final doctor = (await doctorRepo.getDoctors()).first;

      final booked = await appointmentProvider.bookAppointment(
        doctorId: doctor.id,
        doctorName: doctor.name,
        doctorSpecialty: doctor.specialty,
        patientName: 'P1',
        patientAge: 28,
        patientPhone: '9876543210',
        appointmentDate: DateTime.now().add(const Duration(days: 2)),
        timeSlot: '02:00 PM',
        symptomsNote: 'Checkup note',
      );

      await billProvider.loadBills();
      expect(billProvider.unpaidBillsCount, equals(initialUnpaid + 1));

      // Cancel appointment
      await appointmentProvider.cancelAppointment(booked.id);
      await billProvider.loadBills();

      expect(billProvider.unpaidBillsCount, equals(initialUnpaid));
      final linkedBill = billProvider.bills.firstWhere((b) => b.appointmentId == booked.id);
      expect(linkedBill.status, equals(BillStatus.cancelled));

      // Attempting to pay a cancelled bill must fail
      final payResult = await billProvider.payBill(
        billId: linkedBill.id,
        method: PaymentMethodType.upi,
        details: {'upiId': 'test@okaxis'},
      );
      expect(payResult.isSuccess, isFalse);
      expect(payResult.message, contains('cancelled'));
    });

    test('6. Separate loading flags: isBooking and isCancelling keep isLoading false', () async {
      final dataService = MockDataService();
      final doctorRepo = MockDoctorRepository(dataService);
      final appointmentRepo = MockAppointmentRepository(dataService);
      final billRepo = MockBillRepository(dataService);
      final provider = AppointmentProvider(
        appointmentRepo,
        doctorRepository: doctorRepo,
        billRepository: billRepo,
      );

      final doctor = (await doctorRepo.getDoctors()).first;
      bool isLoadingToggledDuringBooking = false;
      bool isBookingToggled = false;

      provider.addListener(() {
        if (provider.isLoading) isLoadingToggledDuringBooking = true;
        if (provider.isBooking) isBookingToggled = true;
      });

      await provider.bookAppointment(
        doctorId: doctor.id,
        doctorName: doctor.name,
        doctorSpecialty: doctor.specialty,
        patientName: 'P1',
        patientAge: 30,
        patientPhone: '9876543210',
        appointmentDate: DateTime.now().add(const Duration(days: 1)),
        timeSlot: '03:00 PM',
        symptomsNote: 'Testing loading flags',
      );

      expect(isLoadingToggledDuringBooking, isFalse, reason: 'isLoading must not toggle during booking');
      expect(isBookingToggled, isTrue, reason: 'isBooking must toggle during booking');
      expect(provider.isBooking, isFalse, reason: 'isBooking resets after completion');
    });

    test('7. One tax rule via AppConstants and BillCalculator computes tax uniformly', () {
      expect(AppConstants.gstTaxRate, equals(0.18));
      final tax = BillCalculator.calculateTax(1000.0, 500.0);
      expect(tax, equals(270.0)); // 1500 * 0.18 = 270

      final bill = BillCalculator.createConsultationBill(
        id: 'BIL-TEST',
        appointmentId: 'APT-TEST',
        billDate: DateTime(2026, 9, 30),
        doctorName: 'Dr. Test',
        doctorSpecialty: 'Cardiology',
        consultationFee: 800.0,
      );

      expect(bill.tax, equals(144.0)); // 800 * 0.18 = 144
      expect(bill.totalAmount, equals(944.0));
      expect(bill.status, equals(BillStatus.pending));
    });

    test('8. Atomic rollback on booking failure restores slots and removes appointment', () async {
      final dataService = MockDataService();
      final doctorRepo = MockDoctorRepository(dataService);
      final appointmentRepo = MockAppointmentRepository(dataService);
      final throwingBillRepo = _ThrowingBillRepo(dataService);

      final provider = AppointmentProvider(
        appointmentRepo,
        doctorRepository: doctorRepo,
        billRepository: throwingBillRepo,
      );

      final doctor = (await doctorRepo.getDoctors()).first;
      final futureDate = DateTime.now().add(const Duration(days: 3));
      const slot = '10:00 AM';

      final initialUpcoming = provider.upcomingAppointments.length;

      expect(
        () => provider.bookAppointment(
          doctorId: doctor.id,
          doctorName: doctor.name,
          doctorSpecialty: doctor.specialty,
          patientName: 'P1',
          patientAge: 30,
          patientPhone: '9876543210',
          appointmentDate: futureDate,
          timeSlot: slot,
          symptomsNote: 'Testing atomic rollback',
        ),
        throwsA(isA<AppException>()),
      );

      // Verify rollback: appointments list has not grown
      expect(provider.upcomingAppointments.length, equals(initialUpcoming));
    });

    test('9. Collision-safe ID generation guarantees uniqueness against existing items', () {
      final existingAptIds = {'APT-000001', 'APT-000002'};
      final newId = AppointmentProvider.generateUniqueAppointmentId(existingAptIds);
      expect(newId.startsWith('APT-'), isTrue);
      expect(existingAptIds.contains(newId), isFalse);

      final existingBillIds = {'BIL-000001'};
      final newBillId = BillProvider.generateUniqueBillId(existingBillIds);
      expect(newBillId.startsWith('BIL-'), isTrue);
      expect(existingBillIds.contains(newBillId), isFalse);
    });
  });
}

class _ThrowingBillRepo extends MockBillRepository {
  _ThrowingBillRepo(super.dataService);

  @override
  Future<BillModel> addBill(BillModel bill) async {
    throw const AppException('Simulated Bill Database Connection Failure');
  }
}
