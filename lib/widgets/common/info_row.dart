import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';

/// Reusable key-value info row with icon, label, and formatted value.
class InfoRow extends StatelessWidget {
  const InfoRow({
    super.key,
    required this.label,
    required this.value,
    this.icon,
    this.bold = false,
    this.highlight = false,
    this.isMonospace = false,
    this.valueColor,
  });

  final String label;
  final String value;
  final IconData? icon;
  final bool bold;
  final bool highlight;
  final bool isMonospace;
  final Color? valueColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final resolvedColor = valueColor ??
        (highlight
            ? AppColors.primary
            : (bold ? colorScheme.onSurface : colorScheme.onSurfaceVariant));

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (icon != null) ...[
            Icon(
              icon,
              size: 16,
              color: highlight ? AppColors.primary : colorScheme.outline,
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
              fontSize: 13,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: bold || highlight ? FontWeight.w700 : FontWeight.w500,
                color: resolvedColor,
                fontFamily: isMonospace ? 'monospace' : null,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
