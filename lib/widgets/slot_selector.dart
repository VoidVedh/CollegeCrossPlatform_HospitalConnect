import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';

/// Interactive accessible date and time-slot selector component.
/// Enforces business rules: past dates/slots and booked slots cannot be selected.
class SlotSelector extends StatelessWidget {
  const SlotSelector({
    super.key,
    required this.doctor,
    required this.selectedDate,
    required this.selectedSlot,
    required this.onDateSelected,
    required this.onSlotSelected,
    this.existingAppointments = const [],
  });

  final DoctorModel doctor;
  final DateTime selectedDate;
  final String? selectedSlot;
  final ValueChanged<DateTime> onDateSelected;
  final ValueChanged<String> onSlotSelected;
  final List<AppointmentModel> existingAppointments;

  static const List<String> standardSlots = [
    '09:00 AM',
    '10:00 AM',
    '10:30 AM',
    '11:00 AM',
    '11:30 AM',
    '02:00 PM',
    '03:00 PM',
    '04:00 PM',
    '04:30 PM',
    '05:00 PM',
  ];

  bool _isSlotBooked(String slot) {
    // Check if slot exists in active appointments for this doctor on selectedDate
    final dateMatch = existingAppointments.any((a) =>
        a.doctorId == doctor.id &&
        a.status == AppointmentStatus.upcoming &&
        a.appointmentDate.year == selectedDate.year &&
        a.appointmentDate.month == selectedDate.month &&
        a.appointmentDate.day == selectedDate.day &&
        a.timeSlot.trim().toLowerCase() == slot.trim().toLowerCase());

    if (dateMatch) return true;

    // Check doctor's listed availableSlots: if availableSlots exist for this date,
    // only those in availableSlots are open.
    final slotsForDate = doctor.availableSlots.where((s) =>
        s.year == selectedDate.year &&
        s.month == selectedDate.month &&
        s.day == selectedDate.day);

    if (slotsForDate.isNotEmpty) {
      final isAvailableInDoctorSchedule = slotsForDate.any((s) {
        final formattedTime = AppFormatters.formatTime(s).trim().toLowerCase();
        return formattedTime == slot.trim().toLowerCase();
      });
      return !isAvailableInDoctorSchedule;
    }

    return false;
  }

  bool _isSlotInPast(String slot) {
    final now = DateTime.now();
    final isToday = selectedDate.year == now.year &&
        selectedDate.month == now.month &&
        selectedDate.day == now.day;

    if (!isToday) return false;

    // Parse slot time (e.g. "09:00 AM" or "02:00 PM")
    try {
      final parts = slot.split(' ');
      final timeParts = parts[0].split(':');
      var hour = int.parse(timeParts[0]);
      final minute = int.parse(timeParts[1]);
      final isPm = parts[1].toUpperCase() == 'PM';

      if (isPm && hour < 12) hour += 12;
      if (!isPm && hour == 12) hour = 0;

      final slotDateTime =
          DateTime(now.year, now.month, now.day, hour, minute);
      return slotDateTime.isBefore(now);
    } catch (_) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Next 14 days
    final days = List.generate(14, (i) => today.add(Duration(days: i)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Date Selector Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Date',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              AppFormatters.formatDate(selectedDate),
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        // Horizontal 14-day date picker cards
        SizedBox(
          height: 78,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: days.length,
            separatorBuilder: (_, _) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final date = days[index];
              final isSelected = date.year == selectedDate.year &&
                  date.month == selectedDate.month &&
                  date.day == selectedDate.day;
              final isToday = date.year == today.year &&
                  date.month == today.month &&
                  date.day == today.day;

              final weekday = [
                'Mon',
                'Tue',
                'Wed',
                'Thu',
                'Fri',
                'Sat',
                'Sun'
              ][date.weekday - 1];

              return InkWell(
                onTap: () => onDateSelected(date),
                borderRadius: BorderRadius.circular(14),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 62,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? colorScheme.primary
                        : colorScheme.surface,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? colorScheme.primary
                          : colorScheme.outlineVariant,
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        isToday ? 'Today' : weekday,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurfaceVariant,
                          fontWeight:
                              isToday ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${date.day}',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: isSelected
                              ? colorScheme.onPrimary
                              : colorScheme.onSurface,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 22),

        // Time Slot Header & Legend
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Select Time Slot',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Row(
              children: [
                _buildLegendItem(
                  colorScheme.surface,
                  'Available',
                  BorderSide(color: colorScheme.outlineVariant),
                ),
                const SizedBox(width: 8),
                _buildLegendItem(
                  Colors.grey.shade200,
                  'Booked',
                  BorderSide(color: Colors.grey.shade300),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Slot Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: standardSlots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            childAspectRatio: 2.6,
          ),
          itemBuilder: (context, index) {
            final slot = standardSlots[index];
            final isBooked = _isSlotBooked(slot);
            final isPast = _isSlotInPast(slot);
            final isDisabled = isBooked || isPast;
            final isSelected = selectedSlot == slot;

            return Semantics(
              button: true,
              enabled: !isDisabled,
              selected: isSelected,
              label: '$slot, ${isDisabled ? "Unavailable" : "Available"}',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isDisabled ? null : () => onSlotSelected(slot),
                  borderRadius: BorderRadius.circular(10),
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : isDisabled
                              ? Colors.grey.shade200
                              : colorScheme.surface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : isDisabled
                                ? Colors.grey.shade300
                                : colorScheme.outlineVariant,
                      ),
                    ),
                    child: Text(
                      slot,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : isDisabled
                                ? Colors.grey.shade500
                                : colorScheme.onSurface,
                        fontWeight:
                            isSelected ? FontWeight.w700 : FontWeight.w500,
                        decoration: isDisabled
                            ? TextDecoration.lineThrough
                            : TextDecoration.none,
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildLegendItem(Color color, String label, BorderSide side) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
            border: Border.fromBorderSide(side),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.outline),
        ),
      ],
    );
  }
}
