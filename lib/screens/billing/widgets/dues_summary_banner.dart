import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';

/// Banner widget displaying the patient's outstanding dues summary.
class DuesSummaryBanner extends StatelessWidget {
  const DuesSummaryBanner({
    super.key,
    required this.totalDues,
    required this.pendingCount,
  });

  final double totalDues;
  final int pendingCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final hasDues = totalDues > 0;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: hasDues
            ? AppColors.primaryContainer.withValues(alpha: 0.6)
            : AppColors.statusCompleted.withValues(alpha: 0.1),
        borderRadius: AppRadius.roundedXl,
        border: Border.all(
          color: hasDues
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.statusCompleted.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
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
                      size: 18,
                      color: hasDues
                          ? AppColors.primary
                          : AppColors.statusCompleted,
                    ),
                    const SizedBox(width: AppSpacing.xs + 2),
                    Text(
                      hasDues ? 'OUTSTANDING DUES' : 'ALL DUES CLEARED',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: hasDues
                            ? AppColors.primary
                            : AppColors.statusCompleted,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.xs + 2),
                Text(
                  AppFormatters.formatCurrency(totalDues),
                  key: const Key('total_outstanding_dues_text'),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: hasDues
                        ? AppColors.primary
                        : AppColors.statusCompleted,
                  ),
                ),
                const SizedBox(height: AppSpacing.xxs),
                Text(
                  hasDues
                      ? '$pendingCount pending invoice${pendingCount > 1 ? 's' : ''} awaiting payment'
                      : 'Zero pending payments across all hospital visits',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: hasDues ? AppColors.primary : AppColors.statusCompleted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasDues ? Icons.account_balance_wallet_rounded : Icons.thumb_up_rounded,
              color: AppColors.surface,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }
}
