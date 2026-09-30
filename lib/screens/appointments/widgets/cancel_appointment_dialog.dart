import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/appointment_model.dart';

/// Confirmation dialog asking user to confirm cancelling their appointment.
class CancelAppointmentDialog extends StatelessWidget {
  const CancelAppointmentDialog({
    super.key,
    required this.appointment,
  });

  final AppointmentModel appointment;

  static Future<bool?> show(
    BuildContext context, {
    required AppointmentModel appointment,
  }) {
    return showDialog<bool>(
      context: context,
      builder: (dialogCtx) => CancelAppointmentDialog(appointment: appointment),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedXl),
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
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Keep Appointment'),
        ),
        FilledButton(
          key: const Key('confirm_cancel_appointment_button'),
          style: FilledButton.styleFrom(backgroundColor: AppColors.error),
          onPressed: () => Navigator.of(context).pop(true),
          child: const Text('Cancel Visit'),
        ),
      ],
    );
  }
}
