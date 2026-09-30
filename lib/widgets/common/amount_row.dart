import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';

/// Reusable financial amount row with consistent currency formatting.
class AmountRow extends StatelessWidget {
  const AmountRow({
    super.key,
    required this.label,
    required this.amount,
    this.isTotal = false,
    this.isDiscount = false,
    this.subtitle,
  });

  final String label;
  final double amount;
  final bool isTotal;
  final bool isDiscount;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final formattedAmount = isDiscount
        ? '- ${AppFormatters.formatCurrency(amount)}'
        : AppFormatters.formatCurrency(amount);

    final amountColor = isTotal
        ? AppColors.primary
        : (isDiscount ? AppColors.statusCompleted : colorScheme.onSurface);

    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: isTotal ? AppSpacing.xs : AppSpacing.xxs,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  label,
                  style: isTotal
                      ? theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        )
                      : theme.textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                ),
                if (subtitle != null) ...[
                  Text(
                    subtitle!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.outline,
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Text(
            formattedAmount,
            style: isTotal
                ? theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: amountColor,
                  )
                : theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: amountColor,
                  ),
          ),
        ],
      ),
    );
  }
}
