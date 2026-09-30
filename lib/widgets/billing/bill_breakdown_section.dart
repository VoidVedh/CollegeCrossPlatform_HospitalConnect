import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/widgets/common/amount_row.dart';

/// Itemized breakdown container for a bill card.
class BillBreakdownSection extends StatelessWidget {
  const BillBreakdownSection({
    super.key,
    required this.bill,
    required this.isPaid,
  });

  final BillModel bill;
  final bool isPaid;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        borderRadius: AppRadius.roundedMd,
      ),
      child: Column(
        children: [
          AmountRow(
            label: 'Doctor Consultation',
            amount: bill.consultationFee,
          ),
          if (bill.labCharges > 0) ...[
            const SizedBox(height: AppSpacing.xs + 2),
            AmountRow(
              label: 'Diagnostics & Lab Tests',
              amount: bill.labCharges,
            ),
          ],
          const SizedBox(height: AppSpacing.xs + 2),
          AmountRow(
            label: 'Applicable GST / Tax',
            amount: bill.tax,
          ),
          const Divider(height: AppSpacing.lg),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payable',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                AppFormatters.formatCurrency(bill.totalAmount),
                key: Key('bill_total_${bill.id}'),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: isPaid ? colorScheme.onSurface : AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
