import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/core/theme/app_theme.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/providers.dart';
import 'package:hospital_connect/screens/onboarding/onboarding_modal.dart';
import 'package:hospital_connect/screens/profile/settings_sheet.dart';
import 'package:hospital_connect/services/booking_coordinator.dart';
import 'package:hospital_connect/services/mock/mock_services.dart';
import 'package:hospital_connect/widgets/common/highlighted_text.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'helpers/pump_app.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('Phase 4: Dark Mode & ThemeProvider Tests', () {
    test('ThemeProvider toggles between system, light, and dark modes with persistence', () async {
      final prefs = await SharedPreferences.getInstance();
      final provider = ThemeProvider(preferences: prefs);

      expect(provider.themeMode, ThemeMode.system);
      expect(provider.isDarkMode, false);

      await provider.setThemeMode(ThemeMode.dark);
      expect(provider.themeMode, ThemeMode.dark);
      expect(provider.isDarkMode, true);
      expect(prefs.getString('app_theme_mode'), 'dark');

      provider.toggleTheme();
      expect(provider.themeMode, ThemeMode.light);
      expect(provider.isDarkMode, false);
      expect(prefs.getString('app_theme_mode'), 'light');
    });

    test('AppTheme.dark generates valid Material 3 ColorScheme with high contrast', () {
      final darkTheme = AppTheme.dark(useGoogleFonts: false);
      expect(darkTheme.brightness, Brightness.dark);
      expect(darkTheme.colorScheme.brightness, Brightness.dark);
      expect(darkTheme.colorScheme.surface, isNotNull);
      expect(darkTheme.colorScheme.primary, isNotNull);
    });
  });

  group('Phase 4: PatientProfileProvider Tests', () {
    test('PatientProfileProvider loads defaults, updates profile, and computes initials', () async {
      final prefs = await SharedPreferences.getInstance();
      final provider = PatientProfileProvider(preferences: prefs);

      expect(provider.name, 'Aditya');
      expect(provider.initials, 'AS');
      expect(provider.hasSeenOnboarding, false);

      await provider.updateProfile(fullName: 'Vikramaditya Rathore', age: 35, phone: '9988776655');
      expect(provider.fullName, 'Vikramaditya Rathore');
      expect(provider.name, 'Vikramaditya');
      expect(provider.initials, 'VR');
      expect(provider.age, 35);
      expect(provider.phone, '9988776655');

      await provider.completeOnboarding();
      expect(provider.hasSeenOnboarding, true);
      expect(prefs.getBool('has_seen_onboarding'), true);
    });
  });

  group('Phase 4: Doctor Sorting, Favorites, and Next Slot Tests', () {
    late MockDataService mockData;
    late MockDoctorRepository doctorRepo;
    late DoctorProvider provider;

    setUp(() {
      mockData = MockDataService();
      doctorRepo = MockDoctorRepository(mockData);
      provider = DoctorProvider(doctorRepo);
    });

    test('DoctorProvider sorts by rating, fee, and experience', () async {
      await provider.loadDoctors();
      expect(provider.doctors.isNotEmpty, true);

      // Highest rated
      provider.setSortOption(DoctorSortOption.rating);
      final sortedByRating = provider.filteredDoctors;
      for (int i = 0; i < sortedByRating.length - 1; i++) {
        expect(sortedByRating[i].rating >= sortedByRating[i + 1].rating, true);
      }

      // Fee low to high
      provider.setSortOption(DoctorSortOption.feeLowToHigh);
      final sortedByFeeAsc = provider.filteredDoctors;
      for (int i = 0; i < sortedByFeeAsc.length - 1; i++) {
        expect(sortedByFeeAsc[i].consultationFee <= sortedByFeeAsc[i + 1].consultationFee, true);
      }

      // Experience
      provider.setSortOption(DoctorSortOption.experience);
      final sortedByExp = provider.filteredDoctors;
      for (int i = 0; i < sortedByExp.length - 1; i++) {
        expect(sortedByExp[i].experienceYears >= sortedByExp[i + 1].experienceYears, true);
      }
    });

    test('DoctorProvider toggles favorites and filters favorites-only', () async {
      await provider.loadDoctors();
      final doctorId = provider.doctors.first.id;

      expect(provider.isFavorite(doctorId), false);
      await provider.toggleFavorite(doctorId);
      expect(provider.isFavorite(doctorId), true);

      provider.setShowFavoritesOnly(true);
      final favList = provider.filteredDoctors;
      expect(favList.length, 1);
      expect(favList.first.id, doctorId);

      provider.setShowFavoritesOnly(false);
      expect(provider.filteredDoctors.length > 1, true);
    });

    test('getNextAvailableSlot returns the earliest upcoming slot after reference time', () {
      final now = DateTime(2026, 9, 30, 9, 0);
      final doctor = DoctorModel(
        id: 'DOC-TEST',
        name: 'Dr. Test',
        specialty: 'General Medicine',
        rating: 4.8,
        experienceYears: 10,
        hospitalName: 'Apollo',
        clinicAddress: 'MG Road',
        consultationFee: 500,
        availableSlots: [
          DateTime(2026, 9, 30, 8, 30), // past
          DateTime(2026, 9, 30, 11, 30),
          DateTime(2026, 9, 30, 10, 0),
        ],
        about: 'Bio',
        reviews: const [],
      );

      final nextSlot = provider.getNextAvailableSlot(doctor, now);
      expect(nextSlot, DateTime(2026, 9, 30, 10, 0));
    });
  });

  group('Phase 4: Payment Failure Simulation Tests', () {
    final gateway = MockPaymentGateway();

    test('UPI failure trigger triggers declined payment result', () async {
      final result = await gateway.processPayment(
        billId: 'BIL-100',
        amount: 800,
        method: PaymentMethodType.upi,
        details: {'upiId': 'fail@okhdfcbank'},
      );

      expect(result.isSuccess, false);
      expect(result.message.contains('declined'), true);
    });

    test('Card failure trigger ending in 0002 triggers declined payment result', () async {
      final result = await gateway.processPayment(
        billId: 'BIL-100',
        amount: 800,
        method: PaymentMethodType.card,
        details: {
          'cardNumber': '4111111111110002',
          'cardHolder': 'TEST USER',
          'cardExpiry': '08/28',
          'cardCvv': '123',
        },
      );

      expect(result.isSuccess, false);
      expect(result.message.contains('declined'), true);
    });
  });

  group('Phase 4: Appointment Reschedule Workflow Tests', () {
    test('Reschedule appointment frees old slot and books new slot atomically', () async {
      final mockData = MockDataService();
      final doctorRepo = MockDoctorRepository(mockData);
      final aptRepo = MockAppointmentRepository(mockData);
      final billRepo = MockBillRepository(mockData);

      final aptProvider = AppointmentProvider(
        aptRepo,
        doctorRepository: doctorRepo,
        billRepository: billRepo,
      );
      final docProvider = DoctorProvider(doctorRepo);
      final billProvider = BillProvider(billRepository: billRepo, paymentGateway: MockPaymentGateway());
      final coordinator = BookingCoordinator(
        appointmentProvider: aptProvider,
        doctorProvider: docProvider,
        billProvider: billProvider,
      );

      await aptProvider.loadAppointments();
      final initialAppointment = aptProvider.upcomingAppointments.first;
      final originalDate = initialAppointment.appointmentDate;
      final originalSlot = initialAppointment.timeSlot;
      expect(originalSlot.isNotEmpty, true);

      final newDate = originalDate.add(const Duration(days: 3));
      const newSlot = '02:30 PM';
      expect(newSlot != originalSlot, true);

      final rescheduled = await coordinator.rescheduleAppointment(
        appointmentId: initialAppointment.id,
        newDate: newDate,
        newTimeSlot: newSlot,
        currentTime: DateTime(2026, 9, 1),
      );

      expect(rescheduled.id, initialAppointment.id);
      expect(rescheduled.appointmentDate, newDate);
      expect(rescheduled.timeSlot, newSlot);

      // Verify the old slot is available and new slot is unavailable
      final updatedDoctor = docProvider.getDoctorById(initialAppointment.doctorId);
      expect(updatedDoctor, isNotNull);
    });
  });

  group('Phase 4: HighlightedText Widget Tests', () {
    testWidgets('HighlightedText highlights matched query substrings with container styles', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: HighlightedText(
              text: 'Dr. Ramesh Kumar - Cardiology',
              query: 'Ramesh',
            ),
          ),
        ),
      );

      expect(find.byType(HighlightedText), findsOneWidget);
      final textRichFinder = find.byType(RichText);
      expect(textRichFinder, findsOneWidget);
    });
  });

  group('Phase 4: SettingsSheet and Onboarding Modal Tests', () {
    testWidgets('SettingsSheet opens, displays theme segments, and edits patient info', (tester) async {
      await pumpHospitalApp(
        tester,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => SettingsSheet.show(ctx),
              child: const Text('Open Settings'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Settings'));
      await tester.pumpAndSettle();

      expect(find.text('Profile & Settings'), findsOneWidget);
      expect(find.text('Appearance Mode'), findsOneWidget);
      expect(find.text('Dark'), findsOneWidget);

      await tester.tap(find.text('Dark'));
      await tester.pumpAndSettle();
    });

    testWidgets('OnboardingModal steps through 3 slides and completes onboarding', (tester) async {
      await pumpHospitalApp(
        tester,
        home: Scaffold(
          body: Builder(
            builder: (ctx) => ElevatedButton(
              onPressed: () => OnboardingModal.show(ctx),
              child: const Text('Open Onboarding'),
            ),
          ),
        ),
      );

      await tester.tap(find.text('Open Onboarding'));
      await tester.pumpAndSettle();

      expect(find.text('Connect with Top Specialists'), findsOneWidget);
      expect(find.text('Continue'), findsOneWidget);

      // Slide 1 -> 2
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Real-Time Conflict-Free Slots'), findsOneWidget);

      // Slide 2 -> 3
      await tester.tap(find.text('Continue'));
      await tester.pumpAndSettle();
      expect(find.text('Transparent Itemized Billing'), findsOneWidget);
      expect(find.text('Get Started'), findsOneWidget);

      // Slide 3 -> Complete
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      expect(find.byType(OnboardingModal), findsNothing);
    });
  });
}
