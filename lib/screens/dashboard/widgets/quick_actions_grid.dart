import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/screens/prescriptions/prescriptions_screen.dart';
import 'package:hospital_connect/widgets/quick_action_card.dart';

/// Quick actions responsive grid (2x2 on mobile, 4x1 on desktop/tablet).
class QuickActionsGrid extends StatelessWidget {
  const QuickActionsGrid({
    super.key,
    required this.onNavigateToTab,
  });

  final void Function(int tabIndex, String routeName) onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: AppSpacing.sm + 2,
          crossAxisSpacing: AppSpacing.sm + 2,
          childAspectRatio: 2.2,
          children: [
            QuickActionCard(
              title: 'Book Visit',
              subtitle: 'Top Doctors',
              icon: Icons.calendar_today_rounded,
              accentColor: AppColors.primary,
              onTap: () => onNavigateToTab(1, '/doctors'),
            ),
            QuickActionCard(
              title: 'Prescriptions',
              subtitle: 'Digital Rx',
              icon: Icons.medication_rounded,
              accentColor: AppColors.secondary,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const PrescriptionsScreen(),
                  ),
                );
              },
            ),
            QuickActionCard(
              title: 'Records',
              subtitle: 'Lab & Scans',
              icon: Icons.folder_shared_rounded,
              accentColor: AppColors.info,
              onTap: () => onNavigateToTab(3, '/records'),
            ),
            QuickActionCard(
              title: 'Pay Bills',
              subtitle: 'Itemized dues',
              icon: Icons.receipt_long_rounded,
              accentColor: AppColors.statusPending,
              onTap: () => onNavigateToTab(4, '/billing'),
            ),
          ],
        );
      },
    );
  }
}
