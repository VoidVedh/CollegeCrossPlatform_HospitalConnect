import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/widgets/common/amount_row.dart';
import 'package:hospital_connect/widgets/common/info_row.dart';
import 'package:hospital_connect/widgets/common/status_badge.dart';

/// Itemized official tax invoice / receipt details container.
class ReceiptDetailsTable extends StatelessWidget {
  const ReceiptDetailsTable({
    super.key,
    required this.bill,
    required this.transactionId,
    required this.paidAt,
  });

  final BillModel bill;
  final String transactionId;
  final DateTime paidAt;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: AppRadius.roundedLg,
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.6),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'RECEIPT / TAX INVOICE',
                    style: theme.textTheme.labelSmall?.copyWith(
                      letterSpacing: 1,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xxs),
                  Text(
                    bill.id,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
              StatusBadge.fromBillStatus(BillStatus.paid, uppercase: true),
            ],
          ),
          const Divider(height: AppSpacing.xxl),

          // Metadata Rows
          InfoRow(
            label: 'Service Name',
            value: bill.serviceName,
          ),
          const SizedBox(height: AppSpacing.sm),
          InfoRow(
            label: 'Transaction ID',
            value: transactionId,
            isMonospace: true,
          ),
          const SizedBox(height: AppSpacing.sm),
          InfoRow(
            label: 'Payment Method',
            value: bill.paymentMethod != null
                ? bill.paymentMethod!.displayName
                : 'Digital Payment',
          ),
          const SizedBox(height: AppSpacing.sm),
          InfoRow(
            label: 'Date & Time',
            value: AppFormatters.formatDateTime(paidAt),
          ),
          if (bill.appointmentId != null) ...[
            const SizedBox(height: AppSpacing.sm),
            InfoRow(
              label: 'Appointment Ref',
              value: bill.appointmentId!,
            ),
          ],
          const Divider(height: AppSpacing.xxl),

          // Charges Breakdown
          Text(
            'ITEMIZED CHARGES',
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w800,
              letterSpacing: 0.8,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: AppSpacing.sm + 2),
          AmountRow(
            label: 'Doctor Consultation Fee',
            amount: bill.consultationFee,
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          AmountRow(
            label: 'Diagnostic / Laboratory Tests',
            amount: bill.labCharges,
          ),
          const SizedBox(height: AppSpacing.xs + 2),
          AmountRow(
            label: 'GST / Taxes (18%)',
            amount: bill.tax,
          ),
          const Divider(height: AppSpacing.xl),

          // Total Paid
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount Paid',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                AppFormatters.formatCurrency(bill.totalAmount),
                key: const Key('receipt_total_amount_text'),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
