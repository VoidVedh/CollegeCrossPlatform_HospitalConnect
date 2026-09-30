import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/appointment_provider.dart';
import 'package:hospital_connect/providers/doctor_provider.dart';
import 'package:hospital_connect/widgets/widgets.dart';
import 'package:provider/provider.dart';

/// Appointment booking screen integrating date and time-slot selection.
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

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    // Default to tomorrow or next available slot date
    _selectedDate =
        DateTime(now.year, now.month, now.day).add(const Duration(days: 1));
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 1. Doctor Brief Info Card
            Container(
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
            ),
            const SizedBox(height: 20),

            // 2. Date and Slot Selector Component
            SlotSelector(
              doctor: doctor,
              selectedDate: _selectedDate,
              selectedSlot: _selectedSlot,
              existingAppointments: appointmentProvider.appointments,
              onDateSelected: (date) {
                setState(() {
                  _selectedDate = date;
                  _selectedSlot = null; // Reset slot on date change
                });
              },
              onSlotSelected: (slot) {
                setState(() {
                  _selectedSlot = slot;
                });
              },
            ),
            const SizedBox(height: 20),

            // 3. Selection Summary Card
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _selectedSlot != null
                    ? AppColors.primary.withValues(alpha: 0.08)
                    : colorScheme.surface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _selectedSlot != null
                      ? AppColors.primary
                      : colorScheme.outlineVariant,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _selectedSlot != null
                        ? Icons.check_circle_rounded
                        : Icons.info_outline_rounded,
                    color: _selectedSlot != null
                        ? AppColors.primary
                        : colorScheme.onSurfaceVariant,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _selectedSlot != null
                          ? 'Selected: ${AppFormatters.formatDate(_selectedDate)} at $_selectedSlot'
                          : 'Please pick an available time slot above to continue.',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: _selectedSlot != null
                            ? AppColors.primary
                            : colorScheme.onSurfaceVariant,
                        fontWeight: _selectedSlot != null
                            ? FontWeight.w700
                            : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // 4. Patient Information Form
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
    );
  }
}
