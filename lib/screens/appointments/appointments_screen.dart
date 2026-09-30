import 'package:flutter/material.dart';
import 'package:hospital_connect/core/errors/app_exceptions.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/appointment_provider.dart';
import 'package:hospital_connect/screens/app_shell.dart';
import 'package:hospital_connect/services/booking_coordinator.dart';
import 'package:provider/provider.dart';

/// Comprehensive Appointments management screen featuring Upcoming, Completed, and Cancelled tabs.
class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _handleCancelAppointment(
    BuildContext context,
    AppointmentModel appointment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogCtx) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: AppColors.error,
            size: 36,
          ),
          title: const Text('Cancel Appointment?'),
          content: Text(
            'Are you sure you want to cancel your appointment with ${appointment.doctorName} on ${AppFormatters.formatDate(appointment.appointmentDate)} at ${appointment.timeSlot}?\n\nThis will immediately free the reserved slot for other patients.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogCtx).pop(false),
              child: const Text('Keep Appointment'),
            ),
            FilledButton(
              key: const Key('confirm_cancel_appointment_button'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.error,
              ),
              onPressed: () => Navigator.of(dialogCtx).pop(true),
              child: const Text('Cancel Visit'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      try {
        final coordinator = context.read<BookingCoordinator?>();
        if (coordinator != null) {
          await coordinator.cancelAppointment(appointment.id);
        } else {
          await context
              .read<AppointmentProvider>()
              .cancelAppointment(appointment.id);
        }

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Appointment ${appointment.id} cancelled. Reserved slot is now freed.',
              ),
              backgroundColor: AppColors.primary,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      } catch (e) {
        if (context.mounted) {
          final message = e is AppException
              ? e.userFriendlyMessage
              : 'Failed to cancel appointment. Please try again.';
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final appointmentProvider = context.watch<AppointmentProvider>();

    final upcoming = appointmentProvider.upcomingAppointments;
    final completed = appointmentProvider.appointments
        .where((a) => a.status == AppointmentStatus.completed)
        .toList();
    final cancelled = appointmentProvider.appointments
        .where((a) => a.status == AppointmentStatus.cancelled)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Appointments'),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: colorScheme.onSurfaceVariant,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          labelStyle: const TextStyle(fontWeight: FontWeight.w700),
          tabs: [
            Tab(text: 'Upcoming (${upcoming.length})'),
            Tab(text: 'Completed (${completed.length})'),
            Tab(text: 'Cancelled (${cancelled.length})'),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh Appointments',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () =>
                context.read<AppointmentProvider>().loadAppointments(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildAppointmentList(
                  context,
                  upcoming,
                  AppointmentStatus.upcoming,
                  theme,
                  colorScheme,
                ),
                _buildAppointmentList(
                  context,
                  completed,
                  AppointmentStatus.completed,
                  theme,
                  colorScheme,
                ),
                _buildAppointmentList(
                  context,
                  cancelled,
                  AppointmentStatus.cancelled,
                  theme,
                  colorScheme,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(
    BuildContext context,
    List<AppointmentModel> items,
    AppointmentStatus status,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (items.isEmpty) {
      return _buildEmptyState(context, status, theme, colorScheme);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AppointmentProvider>().loadAppointments(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 14),
            child: _buildAppointmentCard(context, item, theme, colorScheme),
          );
        },
      ),
    );
  }

  Widget _buildAppointmentCard(
    BuildContext context,
    AppointmentModel apt,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isUpcoming = apt.status == AppointmentStatus.upcoming;
    final isCompleted = apt.status == AppointmentStatus.completed;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUpcoming
              ? AppColors.primary.withValues(alpha: 0.3)
              : colorScheme.outlineVariant,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top Row: Ref ID & Status Badge
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    apt.id,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.primary,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
                _buildStatusBadge(apt.status, theme),
              ],
            ),
            const SizedBox(height: 12),

            // Doctor details
            Row(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                  child: Text(
                    apt.doctorName.replaceAll('Dr. ', '').split(' ').first[0],
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w700,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        apt.doctorName,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        apt.doctorSpecialty,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const Divider(height: 24),

            // Schedule Info
            Row(
              children: [
                Icon(
                  Icons.calendar_month_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  AppFormatters.formatDate(apt.appointmentDate),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 14),
                Icon(
                  Icons.access_time_rounded,
                  size: 16,
                  color: colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Text(
                  apt.timeSlot,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Patient details & symptoms note
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.person_outline_rounded,
                        size: 15,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${apt.patientName} (${apt.patientAge} yrs)',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.notes_rounded,
                        size: 15,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          apt.symptomsNote,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Action triggers
            if (isUpcoming)
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  key: Key('cancel_appointment_btn_${apt.id}'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.error,
                    side: const BorderSide(color: AppColors.error),
                  ),
                  onPressed: () => _handleCancelAppointment(context, apt),
                  icon: const Icon(Icons.cancel_outlined, size: 18),
                  label: const Text(
                    'Cancel Visit',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              )
            else if (isCompleted)
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () {
                    // Navigate to Doctors tab
                    AppShell.selectTab(context, 1);
                  },
                  icon: const Icon(Icons.history_rounded, size: 18),
                  label: const Text('Book Follow-up Consultation'),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                height: 44,
                child: OutlinedButton.icon(
                  onPressed: () {
                    AppShell.selectTab(context, 1);
                  },
                  icon: const Icon(Icons.restart_alt_rounded, size: 18),
                  label: const Text('Re-book Consultation'),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(AppointmentStatus status, ThemeData theme) {
    Color color;
    IconData icon;
    String label;

    switch (status) {
      case AppointmentStatus.upcoming:
        color = AppColors.statusUpcoming;
        icon = Icons.schedule_rounded;
        label = 'UPCOMING';
        break;
      case AppointmentStatus.completed:
        color = AppColors.statusCompleted;
        icon = Icons.check_circle_rounded;
        label = 'COMPLETED';
        break;
      case AppointmentStatus.cancelled:
        color = AppColors.statusCancelled;
        icon = Icons.cancel_rounded;
        label = 'CANCELLED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(
    BuildContext context,
    AppointmentStatus status,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    String title;
    String message;
    IconData icon;

    switch (status) {
      case AppointmentStatus.upcoming:
        title = 'No Upcoming Visits';
        message = 'You have no appointments scheduled. Explore top doctors.';
        icon = Icons.event_available_rounded;
        break;
      case AppointmentStatus.completed:
        title = 'No Completed Visits';
        message = 'Your completed hospital consultation history will appear here.';
        icon = Icons.done_all_rounded;
        break;
      case AppointmentStatus.cancelled:
        title = 'No Cancelled Visits';
        message = 'You have not cancelled any doctor consultations.';
        icon = Icons.event_busy_rounded;
        break;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 68,
              height: 68,
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 34, color: colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (status == AppointmentStatus.upcoming) ...[
              const SizedBox(height: 18),
              FilledButton.icon(
                key: const Key('book_appointment_empty_cta'),
                onPressed: () {
                  AppShell.selectTab(context, 1);
                },
                icon: const Icon(Icons.add_rounded, size: 18),
                label: const Text('Book an Appointment'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
