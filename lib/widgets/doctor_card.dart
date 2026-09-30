import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/widgets/common/doctor_avatar.dart';

/// Card widget displaying a doctor's information, specialty badge, rating,
/// and booking actions.
class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
    required this.onBookVisit,
  });

  final DoctorModel doctor;
  final VoidCallback onTap;
  final VoidCallback onBookVisit;

  Color _getSpecialtyColor(String specialty) {
    switch (specialty.toLowerCase()) {
      case 'cardiology':
        return AppColors.specialtyCardiology;
      case 'neurology':
        return AppColors.specialtyNeurology;
      case 'pediatrics':
        return AppColors.specialtyPediatrics;
      case 'orthopedics':
        return AppColors.specialtyOrthopedics;
      case 'general medicine':
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final specialtyColor = _getSpecialtyColor(doctor.specialty);

    return Semantics(
      button: true,
      label:
          'Doctor ${doctor.name}, ${doctor.specialty}, Rating ${doctor.rating}, Fee ${AppFormatters.formatCurrency(doctor.consultationFee)}',
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: AppSpacing.xs + 2),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.roundedLg,
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        color: colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppRadius.roundedLg,
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Initials Avatar, Doctor Name, Specialty badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DoctorAvatar(
                      name: doctor.name,
                      radius: 26,
                      backgroundColor: specialtyColor.withValues(alpha: 0.12),
                      foregroundColor: specialtyColor,
                      heroTag: 'doctor_avatar_${doctor.id}',
                    ),
                    const SizedBox(width: AppSpacing.md + 2),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          // Specialty Chip Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs + 1,
                            ),
                            decoration: BoxDecoration(
                              color: specialtyColor.withValues(alpha: 0.1),
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: Text(
                              doctor.specialty,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: specialtyColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Rating block
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.xs,
                      ),
                      decoration: const BoxDecoration(
                        color: AppColors.ratingStarContainer,
                        borderRadius: AppRadius.roundedSm,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: AppColors.ratingStar,
                          ),
                          const SizedBox(width: AppSpacing.xs),
                          Text(
                            doctor.rating.toStringAsFixed(1),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: AppColors.ratingStarText,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),

                // Experience & Hospital address info
                Row(
                  children: [
                    Icon(
                      Icons.work_outline_rounded,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs + 2),
                    Text(
                      '${doctor.experienceYears} yrs experience',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.lg),
                    Icon(
                      Icons.local_hospital_outlined,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: AppSpacing.xs + 2),
                    Expanded(
                      child: Text(
                        doctor.hospitalName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md + 2),

                const Divider(height: 1),
                const SizedBox(height: AppSpacing.md),

                // Bottom row: Fee and Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consultation Fee',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          AppFormatters.formatCurrency(doctor.consultationFee),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.md + 2,
                            ),
                            minimumSize: const Size(48, 40),
                          ),
                          child: const Text('Profile'),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        FilledButton(
                          onPressed: onBookVisit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.lg,
                            ),
                            minimumSize: const Size(48, 40),
                          ),
                          child: const Text('Book Visit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
