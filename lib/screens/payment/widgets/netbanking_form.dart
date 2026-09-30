import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';

/// Net Banking bank selection chips and full dropdown selector.
class NetbankingForm extends StatelessWidget {
  const NetbankingForm({
    super.key,
    required this.formKey,
    required this.selectedBank,
    required this.popularBanks,
    required this.allBanks,
    required this.onBankSelected,
  });

  final GlobalKey<FormState> formKey;
  final String selectedBank;
  final List<String> popularBanks;
  final List<String> allBanks;
  final ValueChanged<String> onBankSelected;

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
              'Select Your Bank',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.sm,
              runSpacing: AppSpacing.sm,
              children: popularBanks.map((bank) {
                final isSelected = selectedBank == bank;
                return ChoiceChip(
                  key: Key('bank_chip_$bank'),
                  label: Text(
                    bank.split('(').first.trim(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primaryContainer,
                  onSelected: (selected) {
                    if (selected) {
                      onBankSelected(bank);
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.lg),
            DropdownButtonFormField<String>(
              key: const Key('all_banks_dropdown'),
              initialValue: selectedBank,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'All Supported Indian Banks',
                prefixIcon: Icon(Icons.account_balance_rounded),
              ),
              items: allBanks.map((bank) {
                return DropdownMenuItem<String>(
                  value: bank,
                  child: Text(bank, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (newBank) {
                if (newBank != null) {
                  onBankSelected(newBank);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
