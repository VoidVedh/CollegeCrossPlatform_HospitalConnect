import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/core/utils/clock.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/services/slot_schedule_service.dart';

void main() {
  group('Clock & Deterministic Time Services', () {
    test('SystemClock returns active wall-clock time', () {
      const clock = SystemClock();
      final before = DateTime.now();
      final now = clock.now();
      final after = DateTime.now();

      expect(now.isBefore(before), isFalse);
      expect(now.isAfter(after), isFalse);
    });

    test('FakeClock allows setting, advancing, and rewinding simulated time', () {
      final base = DateTime(2026, 10, 15, 10, 0);
      final clock = FakeClock(base);

      expect(clock.now(), equals(base));

      // Advance
      clock.advance(const Duration(hours: 2, minutes: 30));
      expect(clock.now(), equals(DateTime(2026, 10, 15, 12, 30)));

      // Rewind
      clock.rewind(const Duration(minutes: 30));
      expect(clock.now(), equals(DateTime(2026, 10, 15, 12, 0)));

      // Set explicit time
      final target = DateTime(2026, 11, 1, 9, 0);
      clock.setTime(target);
      expect(clock.now(), equals(target));
    });

    test('SlotScheduleService uses injected Clock for past slot calculations', () {
      final testDate = DateTime(2026, 10, 20);
      // Simulate that current time is 2:15 PM on testDate
      final fakeClock = FakeClock(DateTime(2026, 10, 20, 14, 15));
      final service = SlotScheduleService(clock: fakeClock);

      const doctor = DoctorModel(
        id: 'doc-clock-test',
        name: 'Dr. Clock Test',
        specialty: 'General Medicine',
        experienceYears: 10,
        rating: 4.8,
        reviews: [],
        consultationFee: 500,
        hospitalName: 'General Hospital',
        clinicAddress: 'OPD 1',
        about: 'Test doctor',
        availableSlots: [],
      );

      final slots = service.getSlotsForDoctorAndDate(
        doctor: doctor,
        date: testDate,
        existingAppointments: [],
      );

      // Morning slot (09:00 AM) must be past
      final morningSlot = slots.firstWhere((s) => s.time == '09:00 AM');
      expect(morningSlot.isPast, isTrue);
      expect(morningSlot.isAvailable, isFalse);

      // 02:00 PM slot (14:00) must be past since now is 14:15
      final twoPmSlot = slots.firstWhere((s) => s.time == '02:00 PM');
      expect(twoPmSlot.isPast, isTrue);
      expect(twoPmSlot.isAvailable, isFalse);

      // 02:30 PM slot (14:30) must be future and available
      final twoThirtyPmSlot = slots.firstWhere((s) => s.time == '02:30 PM');
      expect(twoThirtyPmSlot.isPast, isFalse);
      expect(twoThirtyPmSlot.isAvailable, isTrue);

      // Advance clock past 2:30 PM to 2:45 PM
      fakeClock.advance(const Duration(minutes: 30)); // 14:45

      final updatedSlots = service.getSlotsForDoctorAndDate(
        doctor: doctor,
        date: testDate,
        existingAppointments: [],
      );

      final advancedSlot = updatedSlots.firstWhere((s) => s.time == '02:30 PM');
      expect(advancedSlot.isPast, isTrue);
      expect(advancedSlot.isAvailable, isFalse);
    });
  });
}
