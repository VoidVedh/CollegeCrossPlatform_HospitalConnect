import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/services/slot_schedule_service.dart';

/// Accessible grid of time slots with visual availability indicators and legend.
class TimeSlotGrid extends StatelessWidget {
  const TimeSlotGrid({
    super.key,
    required this.slots,
    required this.selectedSlot,
    required this.onSlotSelected,
  });

  final List<DoctorSlot> slots;
  final String? selectedSlot;
  final ValueChanged<String> onSlotSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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
                const SizedBox(width: AppSpacing.sm),
                _buildLegendItem(
                  colorScheme.surfaceContainerHighest,
                  'Booked',
                  BorderSide(color: colorScheme.outlineVariant),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Slot Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: slots.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: AppSpacing.sm,
            crossAxisSpacing: AppSpacing.sm,
            childAspectRatio: 2.6,
          ),
          itemBuilder: (context, index) {
            final slot = slots[index];
            final isDisabled = !slot.isAvailable;
            final isSelected = selectedSlot == slot.time;

            return Semantics(
              button: true,
              enabled: !isDisabled,
              selected: isSelected,
              label:
                  '${slot.time}, ${isDisabled ? (slot.isPast ? "Past" : "Booked") : "Available"}',
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: isDisabled ? null : () => onSlotSelected(slot.time),
                  borderRadius: AppRadius.roundedSm,
                  child: Container(
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? colorScheme.primary
                          : isDisabled
                              ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.6)
                              : colorScheme.surface,
                      borderRadius: AppRadius.roundedSm,
                      border: Border.all(
                        color: isSelected
                            ? colorScheme.primary
                            : isDisabled
                                ? colorScheme.outlineVariant
                                : colorScheme.outlineVariant,
                      ),
                    ),
                    child: Text(
                      slot.time,
                      style: theme.textTheme.labelMedium?.copyWith(
                        color: isSelected
                            ? colorScheme.onPrimary
                            : isDisabled
                                ? colorScheme.onSurfaceVariant.withValues(alpha: 0.6)
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
        const SizedBox(width: AppSpacing.xs),
        Text(
          label,
          style: const TextStyle(fontSize: 10, color: AppColors.outline),
        ),
      ],
    );
  }
}
