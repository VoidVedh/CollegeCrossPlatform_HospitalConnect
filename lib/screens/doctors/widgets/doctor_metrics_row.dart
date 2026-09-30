import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/models/doctor_model.dart';

/// Row of statistic counter tiles (Experience, Rating, Reviews count).
class DoctorMetricsRow extends StatelessWidget {
  const DoctorMetricsRow({
    super.key,
    required this.doctor,
  });

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MetricTile(
            label: 'Experience',
            value: '${doctor.experienceYears}+ Yrs',
            icon: Icons.work_outline_rounded,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: _MetricTile(
            label: 'Rating',
            value: '${doctor.rating} ★',
            icon: Icons.star_rounded,
            iconColor: AppColors.starRating,
          ),
        ),
        const SizedBox(width: AppSpacing.sm + 2),
        Expanded(
          child: _MetricTile(
            label: 'Reviews',
            value: '${doctor.reviews.length}+',
            icon: Icons.rate_review_outlined,
          ),
        ),
      ],
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({
    required this.label,
    required this.value,
    required this.icon,
    this.iconColor,
  });

  final String label;
  final String value;
  final IconData icon;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: AppSpacing.md,
        horizontal: AppSpacing.sm,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.roundedMd,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        children: [
          Icon(icon, size: 20, color: iconColor ?? colorScheme.primary),
          const SizedBox(height: AppSpacing.xs),
          Text(
            value,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppSpacing.xxs),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}
