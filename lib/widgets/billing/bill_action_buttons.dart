import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/widgets/payment_receipt_dialog.dart';

/// Action triggers and status summary footer for a bill card.
class BillActionButtons extends StatelessWidget {
  const BillActionButtons({
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
    final colorScheme = Theme.of(context).colorScheme;

    if (bill.status == BillStatus.paid) {
      return Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: AppSpacing.sm,
            ),
            decoration: BoxDecoration(
              color: AppColors.statusCompleted.withValues(alpha: 0.08),
              borderRadius: AppRadius.roundedSm,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.verified_rounded,
                      size: 16,
                      color: AppColors.statusCompleted,
                    ),
                    const SizedBox(width: AppSpacing.xs + 2),
                    Text(
                      bill.paymentMethod != null
                          ? 'Paid via ${bill.paymentMethod!.displayName}'
                          : 'Paid in Full',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppColors.statusCompleted,
                      ),
                    ),
                  ],
                ),
                if (bill.paidAt != null)
                  Text(
                    AppFormatters.formatDateShort(bill.paidAt!),
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          SizedBox(
            width: double.infinity,
            height: 42,
            child: OutlinedButton.icon(
              key: Key('view_receipt_button_${bill.id}'),
              onPressed: () {
                if (onViewReceipt != null) {
                  onViewReceipt!();
                } else {
                  PaymentReceiptDialog.show(context, bill: bill);
                }
              },
              icon: const Icon(Icons.receipt_long_rounded, size: 16),
              label: const Text(
                'View Payment Receipt',
                style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      );
    }

    if (bill.status == BillStatus.cancelled) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm + 2,
        ),
        decoration: BoxDecoration(
          color: AppColors.statusCancelled.withValues(alpha: 0.08),
          borderRadius: AppRadius.roundedSm,
          border: Border.all(
            color: AppColors.statusCancelled.withValues(alpha: 0.25),
          ),
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 16,
              color: AppColors.statusCancelled,
            ),
            SizedBox(width: AppSpacing.xs + 2),
            Text(
              'Appointment Cancelled - Invoice Voided',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppColors.statusCancelled,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: 48,
      child: FilledButton.icon(
        key: Key('pay_bill_button_${bill.id}'),
        onPressed: onPayPressed,
        icon: const Icon(Icons.payment_rounded),
        label: Text(
          'Pay ${AppFormatters.formatCurrency(bill.totalAmount)} Now',
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
