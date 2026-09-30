import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';

/// Modal dialog shown while payment processing is in-flight.
class PaymentProcessingDialog extends StatelessWidget {
  const PaymentProcessingDialog({super.key, required this.bill});

  final BillModel bill;

  static Future<void> show(BuildContext context, {required BillModel bill}) {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => PaymentProcessingDialog(bill: bill),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return PopScope(
      canPop: false,
      child: AlertDialog(
        shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
        content: Padding(
          padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: AppSpacing.xl),
              Text(
                'Processing Payment...',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                'Authorizing ${AppFormatters.formatCurrency(bill.totalAmount)} securely with your bank.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock_rounded, size: 14, color: AppColors.secondary),
                  SizedBox(width: AppSpacing.xs),
                  Text(
                    '256-bit SSL Encrypted Session',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppColors.secondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
