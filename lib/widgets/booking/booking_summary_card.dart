import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/widgets/common/amount_row.dart';

/// Pre-booking summary cards detailing doctor, patient, and fee breakdown.
class BookingSummaryCards extends StatelessWidget {
  const BookingSummaryCards({
    super.key,
    required this.doctor,
    required this.appointmentDate,
    required this.timeSlot,
    required this.patientName,
    required this.patientAge,
    required this.patientPhone,
    required this.symptomsNote,
    required this.consultationFee,
    required this.tax,
    required this.totalAmount,
  });

  final DoctorModel doctor;
  final DateTime appointmentDate;
  final String timeSlot;
  final String patientName;
  final int patientAge;
  final String patientPhone;
  final String symptomsNote;
  final double consultationFee;
  final double tax;
  final double totalAmount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Doctor Summary Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md + 2),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: AppRadius.roundedLg,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              _buildRow(
                context,
                icon: Icons.medical_services_outlined,
                label: 'Doctor',
                value: doctor.name,
                bold: true,
              ),
              const Divider(height: AppSpacing.lg),
              _buildRow(
                context,
                icon: Icons.local_hospital_outlined,
                label: 'Specialty / Hospital',
                value: '${doctor.specialty} • ${doctor.hospitalName}',
              ),
              const Divider(height: AppSpacing.lg),
              _buildRow(
                context,
                icon: Icons.calendar_today_rounded,
                label: 'Date & Time',
                value: '${AppFormatters.formatDate(appointmentDate)} at $timeSlot',
                highlight: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md + 2),

        // Patient Summary Card
        Container(
          padding: const EdgeInsets.all(AppSpacing.md + 2),
          decoration: BoxDecoration(
            color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: AppRadius.roundedLg,
            border: Border.all(color: colorScheme.outlineVariant),
          ),
          child: Column(
            children: [
              _buildRow(
                context,
                icon: Icons.person_outline_rounded,
                label: 'Patient',
                value: '$patientName ($patientAge yrs)',
              ),
              const Divider(height: AppSpacing.lg),
              _buildRow(
                context,
                icon: Icons.phone_outlined,
                label: 'Contact',
                value: '+91 $patientPhone',
              ),
              const Divider(height: AppSpacing.lg),
              _buildRow(
                context,
                icon: Icons.notes_rounded,
                label: 'Symptoms',
                value: symptomsNote,
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md + 2),

        // Estimated Consultation Charges
        Container(
          padding: const EdgeInsets.all(AppSpacing.md + 2),
          decoration: BoxDecoration(
            color: AppColors.primaryContainer.withValues(alpha: 0.4),
            borderRadius: AppRadius.roundedLg,
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.25),
            ),
          ),
          child: Column(
            children: [
              AmountRow(
                label: 'Consultation Fee',
                amount: consultationFee,
              ),
              const SizedBox(height: AppSpacing.xs + 2),
              AmountRow(
                label: 'Estimated GST (18%)',
                amount: tax,
              ),
              const Divider(height: AppSpacing.lg),
              AmountRow(
                label: 'Total Payable',
                amount: totalAmount,
                isTotal: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool bold = false,
    bool highlight = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: highlight ? AppColors.primary : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: bold || highlight ? FontWeight.w700 : FontWeight.w500,
                  color: highlight ? AppColors.primary : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
