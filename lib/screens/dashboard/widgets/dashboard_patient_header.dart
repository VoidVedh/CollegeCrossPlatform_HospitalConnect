import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/providers/patient_profile_provider.dart';
import 'package:hospital_connect/screens/profile/settings_sheet.dart';
import 'package:provider/provider.dart';

/// Top header banner on the patient dashboard with greeting and emergency SOS pill.
class DashboardPatientHeader extends StatelessWidget {
  const DashboardPatientHeader({
    super.key,
    this.patientName,
    this.patientInitials,
  });

  final String? patientName;
  final String? patientInitials;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final profile = Provider.of<PatientProfileProvider?>(context);
    final effectiveName = patientName ?? profile?.name ?? 'Aditya';
    final effectiveInitials = patientInitials ?? profile?.initials ?? 'AS';

    return LayoutBuilder(
      builder: (context, constraints) {
        final maxGreetingWidth = (constraints.maxWidth - 68).clamp(120.0, double.infinity);

        return Wrap(
          alignment: WrapAlignment.spaceBetween,
          crossAxisAlignment: WrapCrossAlignment.center,
          spacing: AppSpacing.sm,
          runSpacing: AppSpacing.xs,
          children: [
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: () => SettingsSheet.show(context),
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: colorScheme.primaryContainer,
                    child: Text(
                      effectiveInitials,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                ConstrainedBox(
                  constraints: BoxConstraints(maxWidth: maxGreetingWidth),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: () => SettingsSheet.show(context),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                'Hello, $effectiveName 👋',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(width: 4),
                            Icon(Icons.tune_rounded, size: 14, color: colorScheme.onSurfaceVariant),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.xxs),
                        Text(
                          'How are you feeling today?',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm + 2,
                vertical: AppSpacing.xs + 2,
              ),
              decoration: BoxDecoration(
                color: AppColors.error.withValues(alpha: 0.1),
                borderRadius: AppRadius.roundedFull,
                border: Border.all(
                  color: AppColors.error.withValues(alpha: 0.3),
                ),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.emergency_rounded,
                    size: 16,
                    color: AppColors.error,
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    'SOS 108',
                    style: TextStyle(
                      color: AppColors.error,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
