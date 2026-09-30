import 'package:flutter/material.dart';
import 'package:hospital_connect/core/errors/app_exceptions.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/appointment_provider.dart';
import 'package:hospital_connect/screens/app_shell.dart';
import 'package:hospital_connect/screens/appointments/widgets/appointment_card.dart';
import 'package:hospital_connect/screens/appointments/widgets/cancel_appointment_dialog.dart';
import 'package:hospital_connect/services/booking_coordinator.dart';
import 'package:hospital_connect/widgets/common/empty_state.dart';
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
    final confirmed = await CancelAppointmentDialog.show(
      context,
      appointment: appointment,
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
    final colorScheme = Theme.of(context).colorScheme;
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
                _buildAppointmentList(upcoming, AppointmentStatus.upcoming),
                _buildAppointmentList(completed, AppointmentStatus.completed),
                _buildAppointmentList(cancelled, AppointmentStatus.cancelled),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAppointmentList(
    List<AppointmentModel> items,
    AppointmentStatus status,
  ) {
    if (items.isEmpty) {
      return _buildEmptyState(status);
    }

    return RefreshIndicator(
      onRefresh: () => context.read<AppointmentProvider>().loadAppointments(),
      child: ListView.builder(
        padding: const EdgeInsets.all(AppSpacing.lg),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md + 2),
            child: AppointmentCard(
              appointment: item,
              onCancel: () => _handleCancelAppointment(context, item),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.upcoming:
        return EmptyState(
          icon: Icons.event_available_rounded,
          title: 'No Upcoming Visits',
          message: 'You have no appointments scheduled. Explore top doctors.',
          actionLabel: 'Book an Appointment',
          onAction: () => AppShell.selectTab(context, 1),
        );
      case AppointmentStatus.completed:
        return const EmptyState(
          icon: Icons.done_all_rounded,
          title: 'No Completed Visits',
          message:
              'Your completed hospital consultation history will appear here.',
        );
      case AppointmentStatus.cancelled:
        return const EmptyState(
          icon: Icons.event_busy_rounded,
          title: 'No Cancelled Visits',
          message: 'You have not cancelled any doctor consultations.',
        );
    }
  }
}
