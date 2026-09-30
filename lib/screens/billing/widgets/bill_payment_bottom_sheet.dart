import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/screens/payment/payment_screen.dart';
import 'package:hospital_connect/widgets/common/amount_row.dart';

/// Bottom sheet displaying the itemized charges breakdown and payment gateway CTA.
class BillPaymentBottomSheet extends StatelessWidget {
  const BillPaymentBottomSheet({super.key, required this.bill});

  final BillModel bill;

  static Future<void> show(BuildContext context, {required BillModel bill}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => BillPaymentBottomSheet(bill: bill),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
        maxWidth: 640,
      ),
      margin: const EdgeInsets.only(top: AppSpacing.xxl + 8),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.md,
        AppSpacing.xl,
        AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.lg),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: AppRadius.roundedFull,
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Itemized Bill Summary',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Invoice Ref: ${bill.id}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Service info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: AppRadius.roundedMd,
            ),
            child: Text(
              bill.serviceName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Itemized Charges Breakdown
          AmountRow(
            label: 'Consultation Fee',
            amount: bill.consultationFee,
          ),
          const SizedBox(height: AppSpacing.sm),
          AmountRow(
            label: 'Laboratory & Diagnostics',
            amount: bill.labCharges,
          ),
          const SizedBox(height: AppSpacing.sm),
          AmountRow(
            label: 'Tax / GST (18%)',
            amount: bill.tax,
          ),
          const Divider(height: AppSpacing.xxl),

          // Total
          AmountRow(
            label: 'Total Payable Amount',
            amount: bill.totalAmount,
            isTotal: true,
          ),
          const SizedBox(height: AppSpacing.xxl),

          // Proceed Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              key: const Key('proceed_payment_gateway_button'),
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PaymentScreen(billId: bill.id),
                  ),
                );
              },
              icon: const Icon(Icons.lock_rounded, size: 18),
              label: Text(
                'Proceed to Pay ${AppFormatters.formatCurrency(bill.totalAmount)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
