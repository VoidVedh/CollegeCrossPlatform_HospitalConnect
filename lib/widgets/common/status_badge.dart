import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/models/enums.dart';

/// Reusable status badge with icon, label, and high-contrast color styling.
class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key,
    required this.label,
    required this.color,
    this.backgroundColor,
    this.icon,
    this.compact = false,
  });

  final String label;
  final Color color;
  final Color? backgroundColor;
  final IconData? icon;
  final bool compact;

  factory StatusBadge.fromAppointmentStatus(
    AppointmentStatus status, {
    bool uppercase = false,
  }) {
    switch (status) {
      case AppointmentStatus.upcoming:
        return StatusBadge(
          label: uppercase ? 'UPCOMING' : 'Upcoming',
          icon: Icons.access_time_rounded,
          color: AppColors.statusUpcoming,
        );
      case AppointmentStatus.completed:
        return StatusBadge(
          label: uppercase ? 'COMPLETED' : 'Completed',
          icon: Icons.check_circle_rounded,
          color: AppColors.statusCompleted,
        );
      case AppointmentStatus.cancelled:
        return StatusBadge(
          label: uppercase ? 'CANCELLED' : 'Cancelled',
          icon: Icons.cancel_rounded,
          color: AppColors.statusCancelled,
        );
    }
  }

  factory StatusBadge.fromBillStatus(
    BillStatus status, {
    bool uppercase = false,
  }) {
    switch (status) {
      case BillStatus.paid:
        return StatusBadge(
          label: uppercase ? 'PAID' : 'Paid',
          icon: Icons.verified_rounded,
          color: AppColors.statusPaid,
        );
      case BillStatus.unpaid:
        return StatusBadge(
          label: uppercase ? 'UNPAID' : 'Unpaid',
          icon: Icons.pending_rounded,
          color: AppColors.statusUnpaid,
        );
      case BillStatus.pending:
        return StatusBadge(
          label: uppercase ? 'PENDING' : 'Pending',
          icon: Icons.hourglass_top_rounded,
          color: AppColors.statusPending,
        );
      case BillStatus.cancelled:
        return StatusBadge(
          label: uppercase ? 'CANCELLED' : 'Void / Cancelled',
          icon: Icons.block_rounded,
          color: AppColors.statusCancelled,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = backgroundColor ?? color.withValues(alpha: 0.12);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppSpacing.sm : AppSpacing.md,
        vertical: compact ? AppSpacing.xxs : AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: AppRadius.roundedFull,
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: compact ? 12 : 14, color: color),
            SizedBox(width: compact ? AppSpacing.xxs : AppSpacing.xs),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
              fontSize: compact ? 10.5 : 12,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }
}
