import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/providers.dart';
import 'package:hospital_connect/services/mock/mock_services.dart';

void main() {
  group('Provider Layer Unit Tests', () {
    late MockDataService dataService;
    late MockBillRepository billRepo;
    late MockPaymentGateway paymentGateway;
    late MockDoctorRepository doctorRepo;
    late MockMedicalRecordRepository medicalRepo;
    late MockPrescriptionRepository prescriptionRepo;

    setUp(() {
      dataService = MockDataService();
      billRepo = MockBillRepository(dataService);
      paymentGateway = MockPaymentGateway();
      doctorRepo = MockDoctorRepository(dataService);
      medicalRepo = MockMedicalRecordRepository(dataService);
      prescriptionRepo = MockPrescriptionRepository(dataService);
    });

    test('BillProvider edge cases: invalid IDs, paid/cancelled guards, and filters', () async {
      final billProvider = BillProvider(
        billRepository: billRepo,
        paymentGateway: paymentGateway,
      );
      await billProvider.loadBills();

      // Filter getters
      expect(billProvider.paidBills, isA<List<BillModel>>());
      expect(billProvider.cancelledBills, isA<List<BillModel>>());
      expect(billProvider.unpaidBills, isA<List<BillModel>>());

      // ID collision prevention
      final existingIds = {'BIL-AAAAAA', 'BIL-BBBBBB'};
      final newId = BillProvider.generateUniqueBillId(existingIds);
      expect(newId.startsWith('BIL-'), isTrue);
      expect(existingIds.contains(newId), isFalse);

      // payBill non-existent bill
      final notFoundResult = await billProvider.payBill(
        billId: 'NON_EXISTENT_BILL',
        method: PaymentMethodType.upi,
        details: {'upiId': 'test@upi'},
      );
      expect(notFoundResult.isSuccess, isFalse);
      expect(notFoundResult.message, contains('Invoice not found'));

      // cancel non-existent bill returns null
      final cancelNull = await billProvider.cancelBill('NON_EXISTENT_BILL');
      expect(cancelNull, isNull);

      // Cancel a pending bill and attempt to pay it
      final firstPending = billProvider.unpaidBills.first;
      final cancelledBill = await billProvider.cancelBill(firstPending.id);
      expect(cancelledBill?.status, equals(BillStatus.cancelled));

      final payCancelled = await billProvider.payBill(
        billId: firstPending.id,
        method: PaymentMethodType.upi,
        details: {'upiId': 'test@upi'},
      );
      expect(payCancelled.isSuccess, isFalse);
      expect(payCancelled.message, contains('Cannot pay a cancelled invoice'));

      // Attempt to cancel already paid bill returns null
      final firstPaid = billProvider.paidBills.firstOrNull;
      if (firstPaid != null) {
        final cancelPaid = await billProvider.cancelBill(firstPaid.id);
        expect(cancelPaid, isNull);

        final payPaid = await billProvider.payBill(
          billId: firstPaid.id,
          method: PaymentMethodType.upi,
          details: {'upiId': 'test@upi'},
        );
        expect(payPaid.isSuccess, isFalse);
        expect(payPaid.message, contains('already been settled'));
      }
    });

    test('DoctorProvider edge cases: search filters, sorting, and favorites', () async {
      final docProvider = DoctorProvider(doctorRepo);
      await docProvider.loadDoctors();

      expect(docProvider.doctors.isNotEmpty, isTrue);

      // Lookup existing and missing doctor
      final valid = docProvider.getDoctorById('DOC-01');
      expect(valid, isNotNull);
      final missing = docProvider.getDoctorById('DOC-UNKNOWN-999');
      expect(missing, isNull);

      // Search with specialty filter
      docProvider.setSearchQuery('Sharma');
      docProvider.setSpecialty('Cardiology');
      expect(docProvider.filteredDoctors.every((d) => d.specialty.contains('Cardio')), isTrue);

      // Sort options
      docProvider.setSortOption(DoctorSortOption.feeLowToHigh);
      final lowToHigh = docProvider.filteredDoctors;
      if (lowToHigh.length > 1) {
        expect(lowToHigh.first.consultationFee <= lowToHigh.last.consultationFee, isTrue);
      }

      docProvider.setSortOption(DoctorSortOption.experience);
      expect(docProvider.filteredDoctors.isNotEmpty, isTrue);

      // Top rated doctors
      expect(docProvider.topRatedDoctors.length, lessThanOrEqualTo(5));

      // Favorites
      expect(docProvider.isFavorite('DOC-01'), isFalse);
      await docProvider.toggleFavorite('DOC-01');
      expect(docProvider.isFavorite('DOC-01'), isTrue);
      docProvider.setShowFavoritesOnly(true);
      expect(docProvider.filteredDoctors.every((d) => d.id == 'DOC-01'), isTrue);
    });

    test('ThemeProvider: theme mode transitions and toggle', () {
      final themeProvider = ThemeProvider();
      expect(themeProvider.themeMode, equals(ThemeMode.system));

      themeProvider.setThemeMode(ThemeMode.dark);
      expect(themeProvider.themeMode, equals(ThemeMode.dark));
      expect(themeProvider.isDarkMode, isTrue);

      themeProvider.setThemeMode(ThemeMode.light);
      expect(themeProvider.themeMode, equals(ThemeMode.light));
      expect(themeProvider.isDarkMode, isFalse);

      themeProvider.toggleTheme();
      expect(themeProvider.themeMode, equals(ThemeMode.dark));
      expect(themeProvider.isDarkMode, isTrue);
    });

    test('MedicalRecordProvider and PrescriptionProvider: lookup and filters', () async {
      final recordProvider = MedicalRecordProvider(medicalRepo);
      await recordProvider.loadRecords();
      expect(recordProvider.records.isNotEmpty, isTrue);
      final firstRec = recordProvider.records.first;
      expect(recordProvider.getRecordById(firstRec.id), isNotNull);
      expect(recordProvider.getRecordById('INVALID_ID'), isNull);

      final rxProvider = PrescriptionProvider(prescriptionRepo);
      await rxProvider.loadPrescriptions();
      expect(rxProvider.prescriptions.isNotEmpty, isTrue);
      final firstRx = rxProvider.prescriptions.first;
      expect(rxProvider.getPrescriptionById(firstRx.id), isNotNull);
      expect(rxProvider.getPrescriptionById('INVALID_ID'), isNull);
    });
  });
}
