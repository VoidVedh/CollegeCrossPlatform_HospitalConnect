import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/widgets/common/common_widgets.dart';

/// Card widget displaying a doctor's information, specialty badge, rating,
/// favorite toggle, next available slot, and booking actions.
class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
    required this.onBookVisit,
    this.searchQuery = '',
    this.isFavorite = false,
    this.onToggleFavorite,
    this.nextAvailableSlot,
  });

  final DoctorModel doctor;
  final VoidCallback onTap;
  final VoidCallback onBookVisit;
  final String searchQuery;
  final bool isFavorite;
  final VoidCallback? onToggleFavorite;
  final DateTime? nextAvailableSlot;

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
          'Doctor ${doctor.name}, ${doctor.specialty}, Rating ${doctor.rating}, Fee ${AppFormatters.formatCurrency(doctor.consultationFee)}, ${isFavorite ? "Favorited" : "Not favorited"}',
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
                // Top row: Initials Avatar, Doctor Name, Specialty badge, Favorite button, Rating
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
                          HighlightedText(
                            text: doctor.name,
                            query: searchQuery,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppSpacing.sm,
                              vertical: AppSpacing.xxs + 1,
                            ),
                            decoration: BoxDecoration(
                              color: specialtyColor.withValues(alpha: 0.1),
                              borderRadius: AppRadius.roundedSm,
                            ),
                            child: HighlightedText(
                              text: doctor.specialty,
                              query: searchQuery,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: specialtyColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (onToggleFavorite != null)
                      IconButton(
                        icon: Icon(
                          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                          color: isFavorite ? AppColors.error : colorScheme.onSurfaceVariant,
                          size: 22,
                        ),
                        tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                        onPressed: () {
                          HapticFeedback.selectionClick();
                          onToggleFavorite?.call();
                        },
                      ),
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
                      child: HighlightedText(
                        text: doctor.hospitalName,
                        query: searchQuery,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),

                // Next Available Slot banner
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm + 2,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
                    borderRadius: AppRadius.roundedSm,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 14,
                        color: colorScheme.primary,
                      ),
                      const SizedBox(width: AppSpacing.xs + 2),
                      Text(
                        AppFormatters.formatNextSlot(nextAvailableSlot),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.md),

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
                          onPressed: () {
                            HapticFeedback.lightImpact();
                            onBookVisit();
                          },
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
