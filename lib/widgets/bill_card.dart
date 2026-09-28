import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/widgets/payment_receipt_dialog.dart';

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

  Widget _buildStatusBadge(BuildContext context) {
    Color color;
    IconData icon;
    String label;

    switch (bill.status) {
      case BillStatus.paid:
        color = AppColors.statusCompleted;
        icon = Icons.check_circle_rounded;
        label = 'PAID';
        break;
      case BillStatus.unpaid:
        color = AppColors.statusUnpaid;
        icon = Icons.cancel_rounded;
        label = 'UNPAID';
        break;
      case BillStatus.pending:
        color = AppColors.statusPending;
        icon = Icons.hourglass_top_rounded;
        label = 'PENDING';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isPaid = bill.status == BillStatus.paid;

    return Card(
      elevation: 0,
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: isPaid
              ? colorScheme.outlineVariant
              : AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.primaryContainer.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.receipt_long_rounded,
                        size: 16,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      bill.id,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
                _buildStatusBadge(context),
              ],
            ),
            const SizedBox(height: 12),

            // Service Title
            Text(
              bill.serviceName,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),

            // Bill Date & Linked Appointment
            Row(
              children: [
                Icon(
                  Icons.calendar_today_rounded,
                  size: 13,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  AppFormatters.formatDate(bill.billDate),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                if (bill.appointmentId != null) ...[
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(color: colorScheme.onSurfaceVariant),
                  ),
                  const SizedBox(width: 8),
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
            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 12),

            // Itemized Breakdown Box
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildChargeRow(
                    'Doctor Consultation',
                    AppFormatters.formatCurrency(bill.consultationFee),
                    theme,
                  ),
                  if (bill.labCharges > 0) ...[
                    const SizedBox(height: 6),
                    _buildChargeRow(
                      'Diagnostics & Lab Tests',
                      AppFormatters.formatCurrency(bill.labCharges),
                      theme,
                    ),
                  ],
                  const SizedBox(height: 6),
                  _buildChargeRow(
                    'Applicable GST / Tax',
                    AppFormatters.formatCurrency(bill.tax),
                    theme,
                  ),
                  const Divider(height: 14),
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
            ),
            const SizedBox(height: 14),

            // Payment metadata or action button
            if (isPaid)
              Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.statusCompleted.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(10),
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
                            const SizedBox(width: 6),
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
                  const SizedBox(height: 10),
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
              )
            else
              SizedBox(
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
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildChargeRow(String label, String amount, ThemeData theme) {
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
          amount,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
