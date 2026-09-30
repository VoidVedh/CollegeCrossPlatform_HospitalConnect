import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/widgets/common/doctor_avatar.dart';

/// Horizontal carousel displaying top-rated specialist doctor cards.
class TopDoctorsCarousel extends StatelessWidget {
  const TopDoctorsCarousel({
    super.key,
    required this.topDoctors,
    required this.onTapDoctor,
  });

  final List<DoctorModel> topDoctors;
  final ValueChanged<DoctorModel> onTapDoctor;

  @override
  Widget build(BuildContext context) {
    if (topDoctors.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topDoctors.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.md),
        itemBuilder: (context, index) {
          final doctor = topDoctors[index];
          return _TopDoctorItemCard(
            doctor: doctor,
            onTap: () => onTapDoctor(doctor),
          );
        },
      ),
    );
  }
}

class _TopDoctorItemCard extends StatelessWidget {
  const _TopDoctorItemCard({
    required this.doctor,
    required this.onTap,
  });

  final DoctorModel doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 220,
      padding: const EdgeInsets.all(AppSpacing.md + 2),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.roundedLg,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              DoctorAvatar(
                name: doctor.name,
                radius: 20,
              ),
              const SizedBox(width: AppSpacing.sm + 2),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      doctor.specialty,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: AppColors.ratingStar),
              const SizedBox(width: AppSpacing.xs),
              Text(
                doctor.rating.toStringAsFixed(1),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                AppFormatters.formatCurrency(doctor.consultationFee),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: const RoundedRectangleBorder(
                  borderRadius: AppRadius.roundedSm,
                ),
              ),
              child: const Text('Consult', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
