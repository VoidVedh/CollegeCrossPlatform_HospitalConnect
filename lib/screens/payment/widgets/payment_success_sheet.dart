import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/bill_model.dart';
import 'package:hospital_connect/models/enums.dart';
import 'package:hospital_connect/providers/bill_provider.dart';
import 'package:hospital_connect/services/repositories/payment_gateway.dart';
import 'package:hospital_connect/widgets/payment_receipt_dialog.dart';
import 'package:provider/provider.dart';

/// Modal bottom sheet shown upon successful invoice settlement.
class PaymentSuccessSheet extends StatelessWidget {
  const PaymentSuccessSheet({
    super.key,
    required this.bill,
    required this.result,
    required this.selectedMethod,
    required this.onDone,
  });

  final BillModel bill;
  final PaymentResult result;
  final PaymentMethodType selectedMethod;
  final VoidCallback onDone;

  static void show(
    BuildContext context, {
    required BillModel bill,
    required PaymentResult result,
    required PaymentMethodType selectedMethod,
    required VoidCallback onDone,
  }) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.transparent,
      builder: (sheetContext) => PaymentSuccessSheet(
        bill: bill,
        result: result,
        selectedMethod: selectedMethod,
        onDone: onDone,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: 640,
      ),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.xxl,
        AppSpacing.xl,
        AppSpacing.xxl,
        AppSpacing.xxxl,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(
              color: AppColors.statusCompleted,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_rounded,
              color: AppColors.white,
              size: 38,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Payment Successful!',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.w800,
              color: AppColors.statusCompleted,
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Your hospital bill has been settled.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
              borderRadius: AppRadius.roundedLg,
              border: Border.all(color: colorScheme.outlineVariant),
            ),
            child: Column(
              children: [
                _receiptRow(
                  'Transaction ID',
                  result.transactionId,
                  theme,
                  isBold: true,
                ),
                const Divider(height: AppSpacing.lg),
                _receiptRow(
                  'Invoice ID',
                  bill.id,
                  theme,
                ),
                const SizedBox(height: AppSpacing.sm),
                _receiptRow(
                  'Service',
                  bill.serviceName,
                  theme,
                ),
                const SizedBox(height: AppSpacing.sm),
                _receiptRow(
                  'Amount Paid',
                  AppFormatters.formatCurrency(bill.totalAmount),
                  theme,
                  isPrimary: true,
                ),
                const SizedBox(height: AppSpacing.sm),
                _receiptRow(
                  'Payment Method',
                  selectedMethod.displayName,
                  theme,
                ),
                const SizedBox(height: AppSpacing.sm),
                _receiptRow(
                  'Date & Time',
                  AppFormatters.formatDateTime(
                    result.paidAt ?? DateTime.now(),
                  ),
                  theme,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: OutlinedButton.icon(
              key: const Key('view_full_receipt_button'),
              onPressed: () {
                final updatedBill = context
                        .read<BillProvider>()
                        .getBillById(bill.id) ??
                    bill;
                PaymentReceiptDialog.show(
                  context,
                  bill: updatedBill,
                  transactionId: result.transactionId,
                );
              },
              icon: const Icon(Icons.receipt_long_rounded, size: 18),
              label: const Text(
                'View Full Tax Invoice & Receipt',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton(
              key: const Key('return_to_billing_button'),
              onPressed: onDone,
              child: const Text(
                'Done',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _receiptRow(
    String label,
    String value,
    ThemeData theme, {
    bool isBold = false,
    bool isPrimary = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold || isPrimary ? FontWeight.w700 : FontWeight.w500,
            color: isPrimary ? AppColors.primary : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
