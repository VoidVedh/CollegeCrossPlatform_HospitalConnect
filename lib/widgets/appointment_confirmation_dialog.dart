import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/bill_provider.dart';
import 'package:hospital_connect/providers/doctor_provider.dart';
import 'package:hospital_connect/providers/appointment_provider.dart';
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
      final appointmentProvider = context.read<AppointmentProvider>();
      final booked = await appointmentProvider.bookAppointment(
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

      // Refresh doctor slots and bill list across providers if available
      try {
        if (mounted) {
          await Future.wait([
            context.read<DoctorProvider>().loadDoctors(),
            context.read<BillProvider>().loadBills(),
          ]);
        }
      } catch (_) {}

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
          _errorMessage = 'Booking failed: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    if (_bookedAppointment != null) {
      return _buildSuccessView(context, _bookedAppointment!);
    }

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primaryContainer,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.event_available_rounded,
                      color: AppColors.primary,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 14),
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
              const SizedBox(height: 20),

              // Doctor Summary Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    _buildRow(
                      context,
                      icon: Icons.medical_services_outlined,
                      label: 'Doctor',
                      value: widget.doctor.name,
                      bold: true,
                    ),
                    const Divider(height: 16),
                    _buildRow(
                      context,
                      icon: Icons.local_hospital_outlined,
                      label: 'Specialty / Hospital',
                      value: '${widget.doctor.specialty} • ${widget.doctor.hospitalName}',
                    ),
                    const Divider(height: 16),
                    _buildRow(
                      context,
                      icon: Icons.calendar_today_rounded,
                      label: 'Date & Time',
                      value:
                          '${AppFormatters.formatDate(widget.appointmentDate)} at ${widget.timeSlot}',
                      highlight: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Patient Summary Card
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    _buildRow(
                      context,
                      icon: Icons.person_outline_rounded,
                      label: 'Patient',
                      value: '${widget.patientName} (${widget.patientAge} yrs)',
                    ),
                    const Divider(height: 16),
                    _buildRow(
                      context,
                      icon: Icons.phone_outlined,
                      label: 'Contact',
                      value: '+91 ${widget.patientPhone}',
                    ),
                    const Divider(height: 16),
                    _buildRow(
                      context,
                      icon: Icons.notes_rounded,
                      label: 'Symptoms',
                      value: widget.symptomsNote,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 14),

              // Estimated Consultation Charges
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.25),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Consultation Fee',
                          style: theme.textTheme.bodyMedium,
                        ),
                        Text(
                          AppFormatters.formatCurrency(_consultationFee),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Estimated GST (18%)',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                        Text(
                          AppFormatters.formatCurrency(_tax),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Payable',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        Text(
                          AppFormatters.formatCurrency(_totalAmount),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              if (_errorMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  _errorMessage!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _isSubmitting ? null : () => Navigator.of(context).pop(),
                      child: const Text('Edit Details'),
                    ),
                  ),
                  const SizedBox(width: 12),
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
                                color: Colors.white,
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

  Widget _buildSuccessView(BuildContext context, AppointmentModel appointment) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Success Icon Badge
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: AppColors.statusCompleted.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_rounded,
                  color: AppColors.statusCompleted,
                  size: 42,
                ),
              ),
              const SizedBox(height: 16),

              Text(
                'Appointment Confirmed!',
                textAlign: TextAlign.center,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Your doctor appointment has been successfully scheduled.',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),

              // Appointment ID Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withValues(alpha: 0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'APPOINTMENT ID',
                      style: theme.textTheme.labelSmall?.copyWith(
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      appointment.id,
                      key: const Key('confirmed_appointment_id_text'),
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: AppColors.primary,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Summary Details
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildSimpleRow('Doctor', appointment.doctorName),
                    const SizedBox(height: 6),
                    _buildSimpleRow(
                      'Date & Time',
                      '${AppFormatters.formatDate(appointment.appointmentDate)} at ${appointment.timeSlot}',
                    ),
                    const SizedBox(height: 6),
                    _buildSimpleRow('Patient', appointment.patientName),
                    const SizedBox(height: 6),
                    _buildSimpleRow(
                      'Billing',
                      'Pending invoice generated (Pay anytime)',
                      valueColor: AppColors.statusPending,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Action Buttons
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  key: const Key('view_appointments_modal_button'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    // Pop booking screen and navigate to root with appointments tab
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  icon: const Icon(Icons.calendar_month_rounded),
                  label: const Text('Go to Appointments'),
                ),
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  key: const Key('done_booking_modal_button'),
                  onPressed: () {
                    Navigator.of(context).pop(); // Close dialog
                    Navigator.of(context).popUntil((route) => route.isFirst);
                  },
                  child: const Text('Back to Home'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpleRow(String label, String value, {Color? valueColor}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
        ),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: valueColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    bool bold = false,
    bool highlight = false,
  }) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          size: 18,
          color: highlight ? AppColors.primary : colorScheme.onSurfaceVariant,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: bold || highlight ? FontWeight.w700 : FontWeight.w500,
                  color: highlight ? AppColors.primary : null,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
