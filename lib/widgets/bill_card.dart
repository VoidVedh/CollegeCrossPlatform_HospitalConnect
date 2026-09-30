import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/widgets/billing/bill_action_buttons.dart';
import 'package:hospital_connect/widgets/billing/bill_breakdown_section.dart';
import 'package:hospital_connect/widgets/common/status_badge.dart';

/// Card widget displaying an itemized bill with accessible status badge and action triggers.
class BillCard extends StatelessWidget {
  const BillCard({
    super.key,
    required this.bill,
    this.onPayPressed,
    this.onViewReceipt,
  });

  final BillModel bill;
  final VoidCallback? onPayPressed;
  final VoidCallback? onViewReceipt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPaid = bill.status == BillStatus.paid;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.roundedLg,
        side: BorderSide(
          color: isPaid
              ? colorScheme.outlineVariant
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Bill ID & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.xs + 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: AppRadius.roundedSm,
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      bill.id,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                StatusBadge.fromBillStatus(bill.status, uppercase: true),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Service Title
            Text(
              bill.serviceName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),

            // Bill Date & Linked Appointment
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  AppFormatters.formatDate(bill.billDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (bill.appointmentId != null) ...[
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '•',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'Ref: ${bill.appointmentId}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.md + 2),
            const Divider(height: 1),
            const SizedBox(height: AppSpacing.md),

            // Itemized Breakdown Box
            BillBreakdownSection(bill: bill, isPaid: isPaid),
            const SizedBox(height: AppSpacing.md + 2),

            // Payment metadata or action button
            BillActionButtons(
              bill: bill,
              onPayPressed: onPayPressed,
              onViewReceipt: onViewReceipt,
            ),
          ],
        ),
      ),
    );
  }
}
