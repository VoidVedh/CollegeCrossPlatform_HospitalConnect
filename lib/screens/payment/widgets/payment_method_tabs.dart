import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/models/enums.dart';

/// Segmented tab selector for Payment Methods (UPI, Cards, Net Banking).
class PaymentMethodTabs extends StatelessWidget {
  const PaymentMethodTabs({
    super.key,
    required this.selectedMethod,
    required this.onMethodChanged,
  });

  final PaymentMethodType selectedMethod;
  final ValueChanged<PaymentMethodType> onMethodChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _MethodTab(
            type: PaymentMethodType.upi,
            icon: Icons.qr_code_2_rounded,
            label: 'UPI',
            keyName: 'payment_tab_upi',
            isSelected: selectedMethod == PaymentMethodType.upi,
            onTap: () => onMethodChanged(PaymentMethodType.upi),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MethodTab(
            type: PaymentMethodType.card,
            icon: Icons.credit_card_rounded,
            label: 'Card',
            keyName: 'payment_tab_card',
            isSelected: selectedMethod == PaymentMethodType.card,
            onTap: () => onMethodChanged(PaymentMethodType.card),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: _MethodTab(
            type: PaymentMethodType.netBanking,
            icon: Icons.account_balance_rounded,
            label: 'Net Banking',
            keyName: 'payment_tab_net_banking',
            isSelected: selectedMethod == PaymentMethodType.netBanking,
            onTap: () => onMethodChanged(PaymentMethodType.netBanking),
          ),
        ),
      ],
    );
  }
}

class _MethodTab extends StatelessWidget {
  const _MethodTab({
    required this.type,
    required this.icon,
    required this.label,
    required this.keyName,
    required this.isSelected,
    required this.onTap,
  });

  final PaymentMethodType type;
  final IconData icon;
  final String label;
  final String keyName;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Select $label payment method',
      button: true,
      selected: isSelected,
      child: InkWell(
        key: Key(keyName),
        onTap: onTap,
        borderRadius: AppRadius.roundedMd,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(
            vertical: AppSpacing.md,
            horizontal: AppSpacing.xs,
          ),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryContainer
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: AppRadius.roundedMd,
            border: Border.all(
              color: isSelected ? AppColors.primary : colorScheme.outlineVariant,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected
                    ? AppColors.primary
                    : colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(height: AppSpacing.xs),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppColors.primary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
