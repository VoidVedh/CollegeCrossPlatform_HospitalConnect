import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/doctor_model.dart';

/// Sticky bottom navigation bar on Doctor Detail with consultation fee and Book CTA.
class DoctorBookingBar extends StatelessWidget {
  const DoctorBookingBar({
    super.key,
    required this.doctor,
    required this.onBookPressed,
  });

  final DoctorModel doctor;
  final VoidCallback onBookPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.md + 2,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        border: Border(top: BorderSide(color: colorScheme.outlineVariant)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Consultation Fee',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  AppFormatters.formatCurrency(doctor.consultationFee),
                  style: theme.textTheme.titleLarge?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
            FilledButton.icon(
              onPressed: onBookPressed,
              icon: const Icon(Icons.calendar_month_rounded),
              label: const Text('Book Appointment'),
              style: FilledButton.styleFrom(
                minimumSize: const Size(180, 48),
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.roundedMd,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
