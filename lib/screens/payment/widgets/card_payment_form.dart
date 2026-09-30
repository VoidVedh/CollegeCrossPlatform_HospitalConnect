import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/validators.dart';

/// Credit & Debit card payment details form.
class CardPaymentForm extends StatelessWidget {
  const CardPaymentForm({
    super.key,
    required this.formKey,
    required this.cardNumberController,
    required this.cardHolderController,
    required this.cardExpiryController,
    required this.cardCvvController,
    required this.obscureCvv,
    required this.onToggleObscureCvv,
  });

  final GlobalKey<FormState> formKey;
  final TextEditingController cardNumberController;
  final TextEditingController cardHolderController;
  final TextEditingController cardExpiryController;
  final TextEditingController cardCvvController;
  final bool obscureCvv;
  final VoidCallback onToggleObscureCvv;

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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Credit / Debit Card',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    _cardIcon('VISA'),
                    const SizedBox(width: AppSpacing.xs),
                    _cardIcon('MC'),
                    const SizedBox(width: AppSpacing.xs),
                    _cardIcon('RUPAY'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            TextFormField(
              key: const Key('card_number_input_field'),
              controller: cardNumberController,
              validator: AppValidators.validateCardNumber,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              decoration: const InputDecoration(
                labelText: 'Card Number',
                hintText: '16 digit card number',
                prefixIcon: Icon(Icons.credit_card_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextFormField(
              key: const Key('card_holder_input_field'),
              controller: cardHolderController,
              validator: AppValidators.validateName,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Cardholder Name',
                hintText: 'Name as on card',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const Key('card_expiry_input_field'),
                    controller: cardExpiryController,
                    validator: AppValidators.validateCardExpiry,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Expiry (MM/YY)',
                      hintText: '08/28',
                      prefixIcon: Icon(Icons.calendar_month_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextFormField(
                    key: const Key('card_cvv_input_field'),
                    controller: cardCvvController,
                    validator: AppValidators.validateCvv,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    obscureText: obscureCvv,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(4),
                    ],
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          obscureCvv
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: onToggleObscureCvv,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardIcon(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs + 2,
        vertical: AppSpacing.xxs,
      ),
      decoration: const BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: AppRadius.roundedSm,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
