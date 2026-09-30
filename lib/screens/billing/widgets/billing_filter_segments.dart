import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';

/// Horizontal filter segment chips for the billing screen.
class BillingFilterSegments extends StatelessWidget {
  const BillingFilterSegments({
    super.key,
    required this.selectedIndex,
    required this.allCount,
    required this.pendingCount,
    required this.paidCount,
    required this.onSegmentSelected,
  });

  final int selectedIndex;
  final int allCount;
  final int pendingCount;
  final int paidCount;
  final ValueChanged<int> onSegmentSelected;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(context, 0, 'All Bills ($allCount)'),
          const SizedBox(width: AppSpacing.sm),
          _buildChip(context, 1, 'Pending / Due ($pendingCount)'),
          const SizedBox(width: AppSpacing.sm),
          _buildChip(context, 2, 'Paid History ($paidCount)'),
        ],
      ),
    );
  }

  Widget _buildChip(BuildContext context, int index, String label) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isSelected = selectedIndex == index;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) => onSegmentSelected(index),
      showCheckmark: false,
      backgroundColor: colorScheme.surface,
      selectedColor: AppColors.primaryContainer,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? AppColors.primary : colorScheme.onSurface,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.roundedMd,
        side: BorderSide(
          color: isSelected ? AppColors.primary : colorScheme.outlineVariant,
        ),
      ),
    );
  }
}
