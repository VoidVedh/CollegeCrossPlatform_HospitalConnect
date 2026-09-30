import 'package:flutter/material.dart';
import 'package:hospital_connect/core/errors/app_exceptions.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/appointment_provider.dart';
import 'package:hospital_connect/services/booking_coordinator.dart';
import 'package:hospital_connect/widgets/appointment_success_modal.dart';
import 'package:hospital_connect/widgets/booking/booking_summary_card.dart';
import 'package:provider/provider.dart';

/// Shows the interactive pre-booking confirmation dialog followed by success modal.
Future<void> showAppointmentConfirmationDialog({
  required BuildContext context,
  required DoctorModel doctor,
  required DateTime appointmentDate,
  required String timeSlot,
  required String patientName,
  required int patientAge,
  required String patientPhone,
  required String symptomsNote,
  VoidCallback? onBookingSuccess,
}) {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) => AppointmentConfirmationDialog(
      doctor: doctor,
      appointmentDate: appointmentDate,
      timeSlot: timeSlot,
      patientName: patientName,
      patientAge: patientAge,
      patientPhone: patientPhone,
      symptomsNote: symptomsNote,
      onBookingSuccess: onBookingSuccess,
    ),
  );
}

/// Material 3 Appointment Confirmation and Success Dialog.
class AppointmentConfirmationDialog extends StatefulWidget {
  final DoctorModel doctor;
  final DateTime appointmentDate;
  final String timeSlot;
  final String patientName;
  final int patientAge;
  final String patientPhone;
  final String symptomsNote;
  final VoidCallback? onBookingSuccess;

  const AppointmentConfirmationDialog({
    super.key,
    required this.doctor,
    required this.appointmentDate,
    required this.timeSlot,
    required this.patientName,
    required this.patientAge,
    required this.patientPhone,
    required this.symptomsNote,
    this.onBookingSuccess,
  });

  @override
  State<AppointmentConfirmationDialog> createState() =>
      _AppointmentConfirmationDialogState();
}

class _AppointmentConfirmationDialogState
    extends State<AppointmentConfirmationDialog> {
  bool _isSubmitting = false;
  AppointmentModel? _bookedAppointment;
  String? _errorMessage;

  double get _consultationFee => widget.doctor.consultationFee;
  double get _tax => (_consultationFee * 0.18).roundToDouble();
  double get _totalAmount => _consultationFee + _tax;

  Future<void> _handleConfirm() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final coordinator = context.read<BookingCoordinator?>();
      final AppointmentModel booked;
      if (coordinator != null) {
        booked = await coordinator.bookAppointment(
          doctorId: widget.doctor.id,
          doctorName: widget.doctor.name,
          doctorSpecialty: widget.doctor.specialty,
          patientName: widget.patientName,
          patientAge: widget.patientAge,
          patientPhone: widget.patientPhone,
          appointmentDate: widget.appointmentDate,
          timeSlot: widget.timeSlot,
          symptomsNote: widget.symptomsNote,
          consultationFee: _consultationFee,
        );
      } else {
        booked = await context.read<AppointmentProvider>().bookAppointment(
              doctorId: widget.doctor.id,
              doctorName: widget.doctor.name,
              doctorSpecialty: widget.doctor.specialty,
              patientName: widget.patientName,
              patientAge: widget.patientAge,
              patientPhone: widget.patientPhone,
              appointmentDate: widget.appointmentDate,
              timeSlot: widget.timeSlot,
              symptomsNote: widget.symptomsNote,
              consultationFee: _consultationFee,
            );
      }

      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _bookedAppointment = booked;
        });
        widget.onBookingSuccess?.call();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
          _errorMessage = e is AppException
              ? e.userFriendlyMessage
              : 'Booking failed. Please check details and try again.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_bookedAppointment != null) {
      return AppointmentSuccessModal(appointment: _bookedAppointment!);
    }

    return Dialog(
      shape: const RoundedRectangleBorder(borderRadius: AppRadius.roundedXxl),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.sm + 2),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: AppRadius.roundedMd,
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md + 2),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Confirm Appointment',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          'Please review your details below',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.xl),

              // Summary Cards
              BookingSummaryCards(
                doctor: widget.doctor,
                appointmentDate: widget.appointmentDate,
                timeSlot: widget.timeSlot,
                patientName: widget.patientName,
                patientAge: widget.patientAge,
                patientPhone: widget.patientPhone,
                symptomsNote: widget.symptomsNote,
                consultationFee: _consultationFee,
                tax: _tax,
                totalAmount: _totalAmount,
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: AppSpacing.md),
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: AppSpacing.xxl),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed:
                          _isSubmitting ? null : () => Navigator.of(context).pop(),
                      child: const Text('Edit Details'),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: FilledButton(
                      key: const Key('confirm_booking_dialog_button'),
                      onPressed: _isSubmitting ? null : _handleConfirm,
                      child: _isSubmitting
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: AppColors.surface,
                              ),
                            )
                          : const Text('Confirm & Book'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
