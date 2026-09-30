import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';

/// Banner widget displaying the patient's outstanding dues summary and paid this month metric.
class DuesSummaryBanner extends StatelessWidget {
  const DuesSummaryBanner({
    super.key,
    required this.totalDues,
    required this.pendingCount,
    this.paidThisMonth = 0.0,
  });

  final double totalDues;
  final int pendingCount;
  final double paidThisMonth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasDues = totalDues > 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: AppRadius.roundedXl,
        border: Border.all(
          color: colorScheme.outlineVariant,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          hasDues
                              ? Icons.pending_actions_rounded
                              : Icons.check_circle_rounded,
                          size: 16,
                          color: hasDues
                              ? AppColors.primary
                              : AppColors.statusCompleted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          hasDues ? 'OUTSTANDING DUES' : 'ALL DUES CLEARED',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: hasDues
                                ? AppColors.primary
                                : AppColors.statusCompleted,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppFormatters.formatCurrency(totalDues),
                      key: const Key('total_outstanding_dues_text'),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: hasDues ? colorScheme.onSurface : AppColors.statusCompleted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      hasDues
                          ? '$pendingCount pending invoice${pendingCount > 1 ? "s" : ""}'
                          : 'All dues settled in full',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                height: 54,
                width: 1,
                color: colorScheme.outlineVariant,
                margin: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          Icons.verified_rounded,
                          size: 16,
                          color: AppColors.statusCompleted,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'PAID THIS MONTH',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.statusCompleted,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.8,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppFormatters.formatCurrency(paidThisMonth),
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.statusCompleted,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Cleared payments',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
