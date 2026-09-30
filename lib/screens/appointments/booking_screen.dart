import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/appointment_provider.dart';
import 'package:hospital_connect/providers/doctor_provider.dart';
import 'package:hospital_connect/providers/patient_profile_provider.dart';
import 'package:hospital_connect/widgets/widgets.dart';
import 'package:provider/provider.dart';

/// Appointment booking screen with progress stepper and unsaved changes guard.
class BookingScreen extends StatefulWidget {
  const BookingScreen({
    super.key,
    this.doctor,
    this.doctorId,
  }) : assert(
          doctor != null || doctorId != null,
          'Either doctor or doctorId must be provided',
        );

  final DoctorModel? doctor;
  final String? doctorId;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  late DateTime _selectedDate;
  String? _selectedSlot;
  bool _isFormDirty = false;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
  }

  Future<bool> _confirmDiscard() async {
    if (!_isFormDirty && _selectedSlot == null) return true;
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Discard Booking?'),
        content: const Text(
          'You have unconfirmed booking details. Are you sure you want to go back?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Keep Editing'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  void _handleBookingSubmit({
    required DoctorModel doctor,
    required String patientName,
    required int patientAge,
    required String patientPhone,
    required String symptomsNote,
  }) {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an appointment time slot.'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showAppointmentConfirmationDialog(
      context: context,
      doctor: doctor,
      appointmentDate: _selectedDate,
      timeSlot: _selectedSlot!,
      patientName: patientName,
      patientAge: patientAge,
      patientPhone: patientPhone,
      symptomsNote: symptomsNote,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final doctorProvider = context.watch<DoctorProvider>();
    final activeDoctor = (widget.doctorId != null
            ? doctorProvider.getDoctorById(widget.doctorId!)
            : null) ??
        widget.doctor ??
        (widget.doctor != null
            ? doctorProvider.getDoctorById(widget.doctor!.id)
            : null);

    if (activeDoctor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Book Appointment')),
        body: const Center(child: Text('Doctor details not found.')),
      );
    }
    final doctor = activeDoctor;
    final appointmentProvider = context.watch<AppointmentProvider>();
    final patientProfile = Provider.of<PatientProfileProvider?>(context);

    final currentStep = _selectedSlot == null ? 0 : 1;

    return PopScope(
      canPop: !_isFormDirty && _selectedSlot == null,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        final shouldLeave = await _confirmDiscard();
        if (shouldLeave && context.mounted) {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Book Appointment'),
        ),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            children: [
              _buildStepper(theme, colorScheme, currentStep),
              const SizedBox(height: 16),
              _buildDoctorBrief(theme, colorScheme, doctor),
              const SizedBox(height: 20),
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
              const SizedBox(height: 16),
              _buildSelectionBanner(theme, colorScheme),
              const SizedBox(height: 20),
              Card(
                elevation: 0,
                color: colorScheme.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: colorScheme.outlineVariant),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: PatientBookingForm(
                    isSlotSelected: _selectedSlot != null,
                    initialName: patientProfile?.fullName,
                    initialAge: patientProfile?.age.toString(),
                    initialPhone: patientProfile?.phone,
                    onFormDirtyChanged: (dirty) {
                      setState(() {
                        _isFormDirty = dirty;
                      });
                    },
                    onSubmit: ({
                      required patientName,
                      required patientAge,
                      required patientPhone,
                      required symptomsNote,
                    }) =>
                        _handleBookingSubmit(
                      doctor: doctor,
                      patientName: patientName,
                      patientAge: patientAge,
                      patientPhone: patientPhone,
                      symptomsNote: symptomsNote,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepper(ThemeData theme, ColorScheme colorScheme, int currentStep) {
    const steps = ['Choose Slot', 'Patient Details', 'Confirm'];
    return Row(
      children: List.generate(steps.length * 2 - 1, (index) {
        if (index.isOdd) {
          final stepBefore = index ~/ 2;
          final isCompleted = currentStep > stepBefore;
          return Expanded(
            child: Container(
              height: 2,
              color: isCompleted ? colorScheme.primary : colorScheme.outlineVariant,
            ),
          );
        }
        final stepIdx = index ~/ 2;
        final isActive = stepIdx == currentStep;
        final isPassed = stepIdx < currentStep;

        return Column(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: isPassed
                  ? colorScheme.primary
                  : (isActive ? colorScheme.primaryContainer : colorScheme.surfaceContainerHighest),
              child: isPassed
                  ? Icon(Icons.check, size: 14, color: colorScheme.onPrimary)
                  : Text(
                      '${stepIdx + 1}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: isActive ? colorScheme.onPrimaryContainer : colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
            const SizedBox(height: 4),
            Text(
              steps[stepIdx],
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                color: isActive ? colorScheme.primary : colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        );
      }),
    );
  }

  Widget _buildDoctorBrief(ThemeData theme, ColorScheme colorScheme, DoctorModel doctor) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 24,
            backgroundColor: colorScheme.primaryContainer,
            child: Text(
              doctor.name
                  .split(' ')
                  .where((p) => p.isNotEmpty && p != 'Dr.')
                  .map((p) => p[0])
                  .take(2)
                  .join(),
              style: TextStyle(
                color: colorScheme.onPrimaryContainer,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  doctor.specialty,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Fee: ${AppFormatters.formatCurrency(doctor.consultationFee)}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelectionBanner(ThemeData theme, ColorScheme colorScheme) {
    final isSelected = _selectedSlot != null;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.primary.withValues(alpha: 0.08) : colorScheme.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSelected ? AppColors.primary : colorScheme.outlineVariant,
        ),
      ),
      child: Row(
        children: [
          Icon(
            isSelected ? Icons.check_circle_rounded : Icons.info_outline_rounded,
            color: isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              isSelected
                  ? 'Selected: ${AppFormatters.formatDate(_selectedDate)} at $_selectedSlot'
                  : 'Please pick an available time slot above to continue.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
