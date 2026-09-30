import 'package:flutter/foundation.dart';
import 'package:hospital_connect/core/constants/app_constants.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';

/// Representation of a single scheduled time slot for doctor consultation.
@immutable
class DoctorSlot {
  const DoctorSlot({
    required this.time,
    required this.dateTime,
    required this.isBooked,
    required this.isPast,
    required this.isAvailable,
  });

  /// 12-hour formatted time (e.g. "09:00 AM").
  final String time;

  /// Absolute date and time for the slot.
  final DateTime dateTime;

  /// True if already booked by an active appointment or excluded by doctor.
  final bool isBooked;

  /// True if the slot time has already passed for today.
  final bool isPast;

  /// True if the slot can be selected and booked.
  final bool isAvailable;

  @override
  String toString() =>
      'DoctorSlot($time, available: $isAvailable, booked: $isBooked, past: $isPast)';
}

/// Single source of truth generating deterministic time-slot availability grids.
class SlotScheduleService {
  const SlotScheduleService();

  /// Standard working hours template (09:00 to 17:30 in 30-min steps, excluding lunch gap 13:00-14:00).
  List<DateTime> generateWorkingHoursTemplate(DateTime date) {
    final slots = <DateTime>[];
    DateTime current = DateTime(
      date.year,
      date.month,
      date.day,
      AppConstants.workdayStartHour,
      AppConstants.workdayStartMinute,
    );
    final end = DateTime(
      date.year,
      date.month,
      date.day,
      AppConstants.workdayEndHour,
      AppConstants.workdayEndMinute,
    );

    while (!current.isAfter(end)) {
      // Exclude lunch gap
      if (current.hour >= AppConstants.lunchBreakStartHour &&
          current.hour < AppConstants.lunchBreakEndHour) {
        current = current.add(
          const Duration(minutes: AppConstants.slotDurationMinutes),
        );
        continue;
      }
      slots.add(current);
      current = current.add(
        const Duration(minutes: AppConstants.slotDurationMinutes),
      );
    }
    return slots;
  }

  /// Generates the complete time-slot grid for a doctor on a specific date.
  List<DoctorSlot> getSlotsForDoctorAndDate({
    required DoctorModel doctor,
    required DateTime date,
    required List<AppointmentModel> existingAppointments,
    DateTime? now,
  }) {
    final currentTime = now ?? DateTime.now();
    final template = generateWorkingHoursTemplate(date);

    return template.map((slotDateTime) {
      final timeStr = AppFormatters.formatTime(slotDateTime);

      // Check if slot has already passed
      final isPast = slotDateTime.isBefore(currentTime);

      // Check if booked in active appointments
      final isBookedInAppointments = existingAppointments.any((a) {
        if (a.doctorId != doctor.id || a.status != AppointmentStatus.upcoming) {
          return false;
        }
        return a.appointmentDate.year == date.year &&
            a.appointmentDate.month == date.month &&
            a.appointmentDate.day == date.day &&
            a.timeSlot.trim().toLowerCase() == timeStr.trim().toLowerCase();
      });

      // Also check if doctor has explicitly configured availableSlots:
      // If doctor.availableSlots has explicit entries for this specific date,
      // slots not in availableSlots are considered unavailable.
      final doctorSlotsOnDate = doctor.availableSlots.where(
        (s) =>
            s.year == date.year && s.month == date.month && s.day == date.day,
      );
      final isExcludedByDoctorSchedule = doctorSlotsOnDate.isNotEmpty &&
          !doctorSlotsOnDate.any((s) =>
              s.hour == slotDateTime.hour && s.minute == slotDateTime.minute);

      final isBooked = isBookedInAppointments || isExcludedByDoctorSchedule;
      final isAvailable = !isBooked && !isPast;

      return DoctorSlot(
        time: timeStr,
        dateTime: slotDateTime,
        isBooked: isBooked,
        isPast: isPast,
        isAvailable: isAvailable,
      );
    }).toList();
  }
}
