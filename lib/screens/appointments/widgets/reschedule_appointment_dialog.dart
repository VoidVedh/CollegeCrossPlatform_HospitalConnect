import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/appointment_provider.dart';
import 'package:hospital_connect/providers/doctor_provider.dart';
import 'package:hospital_connect/services/booking_coordinator.dart';
import 'package:hospital_connect/widgets/slot_selector.dart';
import 'package:provider/provider.dart';

/// Modal dialog allowing patients to select a new date/time slot to reschedule an appointment.
class RescheduleAppointmentDialog extends StatefulWidget {
  const RescheduleAppointmentDialog({
    super.key,
    required this.appointment,
  });

  final AppointmentModel appointment;

  static Future<bool?> show(BuildContext context, {required AppointmentModel appointment}) {
    return showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => RescheduleAppointmentDialog(appointment: appointment),
    );
  }

  @override
  State<RescheduleAppointmentDialog> createState() => _RescheduleAppointmentDialogState();
}

class _RescheduleAppointmentDialogState extends State<RescheduleAppointmentDialog> {
  late DateTime _selectedDate;
  String? _selectedSlot;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }

  Future<void> _handleConfirm(DoctorModel doctor) async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a new time slot.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    HapticFeedback.lightImpact();

    try {
      final coordinator = context.read<BookingCoordinator>();
      await coordinator.rescheduleAppointment(
        appointmentId: widget.appointment.id,
        newDate: _selectedDate,
        newTimeSlot: _selectedSlot!,
      );

      if (!mounted) return;
      Navigator.of(context).pop(true);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Rescheduled to ${AppFormatters.formatDate(_selectedDate)} at $_selectedSlot',
          ),
          backgroundColor: AppColors.statusCompleted,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSubmitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Rescheduling failed: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final doctorProvider = context.watch<DoctorProvider>();
    final appointmentProvider = context.watch<AppointmentProvider>();
    final doctor = doctorProvider.getDoctorById(widget.appointment.doctorId);

    if (doctor == null) {
      return Container(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        color: colorScheme.surface,
        child: const Text('Doctor details unavailable.'),
      );
    }

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
        maxWidth: 640,
      ),
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, AppSpacing.xxl),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: AppSpacing.md),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: AppRadius.roundedFull,
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Reschedule Visit',
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          Text(
            'Choose a new date and time for Dr. ${doctor.name}',
            style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.md),
          Expanded(
            child: ListView(
              children: [
                SlotSelector(
                  doctor: doctor,
                  selectedDate: _selectedDate,
                  selectedSlot: _selectedSlot,
                  existingAppointments: appointmentProvider.appointments,
                  onDateSelected: (date) {
                    setState(() {
                      _selectedDate = date;
                      _selectedSlot = null;
                    });
                  },
                  onSlotSelected: (slot) {
                    setState(() {
                      _selectedSlot = slot;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.lg),
              ],
            ),
          ),
          SizedBox(
            width: double.infinity,
            height: 48,
            child: FilledButton.icon(
              onPressed: _isSubmitting ? null : () => _handleConfirm(doctor),
              icon: _isSubmitting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.update_rounded),
              label: Text(_isSubmitting ? 'Updating...' : 'Confirm Reschedule'),
            ),
          ),
        ],
      ),
    );
  }
}
