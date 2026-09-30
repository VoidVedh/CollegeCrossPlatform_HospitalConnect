import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/validators.dart';

/// UPI input form and quick-fill handle chips.
class UpiPaymentForm extends StatelessWidget {
  const UpiPaymentForm({
    super.key,
    required this.formKey,
    required this.controller,
    required this.onHandleSelected,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController controller;
  final ValueChanged<String> onHandleSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: formKey,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: AppRadius.roundedLg,
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unified Payments Interface (UPI)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              'Pay directly from your bank account using your virtual payment address.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              key: const Key('upi_id_input_field'),
              controller: controller,
              validator: AppValidators.validateUpiId,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'UPI ID / VPA',
                hintText: 'e.g. mobile@upi or username@okhdfcbank',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Popular UPI Apps:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: [
                _upiChip('Google Pay', '@okhdfcbank'),
                _upiChip('PhonePe', '@ybl'),
                _upiChip('Paytm', '@paytm'),
                _upiChip('BHIM UPI', '@upi'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _upiChip(String label, String handle) {
    return ActionChip(
      avatar: const Icon(Icons.bolt_rounded, size: 16, color: AppColors.primary),
      label: Text(label),
      onPressed: () => onHandleSelected(handle),
    );
  }
}
