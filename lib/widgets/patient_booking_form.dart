import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/utils/validators.dart';

/// Callback signature when valid patient booking details are submitted.
typedef PatientBookingCallback = void Function({
  required String patientName,
  required int patientAge,
  required String patientPhone,
  required String symptomsNote,
});

/// A validated Material 3 patient information form for appointment bookings
/// with focus traversal and auto-focus on invalid fields.
class PatientBookingForm extends StatefulWidget {
  final bool isSlotSelected;
  final PatientBookingCallback onSubmit;
  final VoidCallback? onSlotNeeded;
  final String? initialName;
  final String? initialAge;
  final String? initialPhone;
  final String? initialSymptoms;
  final ValueChanged<bool>? onFormDirtyChanged;

  const PatientBookingForm({
    super.key,
    required this.isSlotSelected,
    required this.onSubmit,
    this.onSlotNeeded,
    this.initialName,
    this.initialAge,
    this.initialPhone,
    this.initialSymptoms,
    this.onFormDirtyChanged,
  });

  @override
  State<PatientBookingForm> createState() => _PatientBookingFormState();
}

class _PatientBookingFormState extends State<PatientBookingForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _ageController;
  late final TextEditingController _phoneController;
  late final TextEditingController _symptomsController;

  final FocusNode _nameFocus = FocusNode();
  final FocusNode _ageFocus = FocusNode();
  final FocusNode _phoneFocus = FocusNode();
  final FocusNode _symptomsFocus = FocusNode();

  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '')
      ..addListener(_checkDirty);
    _ageController = TextEditingController(text: widget.initialAge ?? '')
      ..addListener(_checkDirty);
    _phoneController = TextEditingController(text: widget.initialPhone ?? '')
      ..addListener(_checkDirty);
    _symptomsController =
        TextEditingController(text: widget.initialSymptoms ?? '')
          ..addListener(_checkDirty);
  }

  void _checkDirty() {
    final hasContent = _nameController.text.isNotEmpty ||
        _ageController.text.isNotEmpty ||
        _phoneController.text.isNotEmpty ||
        _symptomsController.text.isNotEmpty;
    if (hasContent != _isDirty) {
      _isDirty = hasContent;
      widget.onFormDirtyChanged?.call(_isDirty);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    _symptomsController.dispose();
    _nameFocus.dispose();
    _ageFocus.dispose();
    _phoneFocus.dispose();
    _symptomsFocus.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (!widget.isSlotSelected) {
      widget.onSlotNeeded?.call();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(
            children: [
              Icon(Icons.schedule_rounded, color: Colors.white, size: 20),
              SizedBox(width: 10),
              Expanded(
                child: Text('Please select an appointment time slot above.'),
              ),
            ],
          ),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final isNameValid = AppValidators.validateName(_nameController.text.trim()) == null;
    final isAgeValid = AppValidators.validateAge(_ageController.text.trim()) == null;
    final isPhoneValid = AppValidators.validatePhone(_phoneController.text.trim()) == null;
    final isSymptomsValid = AppValidators.validateSymptoms(_symptomsController.text.trim()) == null;

    if (!isNameValid) {
      _nameFocus.requestFocus();
    } else if (!isAgeValid) {
      _ageFocus.requestFocus();
    } else if (!isPhoneValid) {
      _phoneFocus.requestFocus();
    } else if (!isSymptomsValid) {
      _symptomsFocus.requestFocus();
    }

    if (_formKey.currentState?.validate() ?? false) {
      HapticFeedback.lightImpact();
      widget.onSubmit(
        patientName: _nameController.text.trim(),
        patientAge: int.parse(_ageController.text.trim()),
        patientPhone: _phoneController.text.trim(),
        symptomsNote: _symptomsController.text.trim(),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.person_pin_rounded,
                size: 20,
                color: colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Text(
                'Patient Information',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // 1. Full Name
          TextFormField(
            key: const Key('patient_name_field'),
            controller: _nameController,
            focusNode: _nameFocus,
            textCapitalization: TextCapitalization.words,
            keyboardType: TextInputType.name,
            validator: AppValidators.validateName,
            decoration: const InputDecoration(
              labelText: 'Full Name *',
              hintText: 'e.g. Ramesh Kumar',
              prefixIcon: Icon(Icons.person_outline_rounded),
            ),
          ),
          const SizedBox(height: 16),

          // 2. Age and Phone row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Age Field
              SizedBox(
                width: 110,
                child: TextFormField(
                  key: const Key('patient_age_field'),
                  controller: _ageController,
                  focusNode: _ageFocus,
                  keyboardType: TextInputType.number,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  validator: AppValidators.validateAge,
                  decoration: const InputDecoration(
                    labelText: 'Age *',
                    hintText: '28',
                    prefixIcon: Icon(Icons.cake_outlined),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              // Phone Field
              Expanded(
                child: TextFormField(
                  key: const Key('patient_phone_field'),
                  controller: _phoneController,
                  focusNode: _phoneFocus,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(10),
                  ],
                  validator: AppValidators.validatePhone,
                  decoration: const InputDecoration(
                    labelText: 'Mobile Number *',
                    hintText: '9876543210',
                    prefixIcon: Icon(Icons.phone_outlined),
                    prefixText: '+91 ',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 3. Symptoms / Reason for Consultation
          TextFormField(
            key: const Key('patient_symptoms_field'),
            controller: _symptomsController,
            focusNode: _symptomsFocus,
            keyboardType: TextInputType.multiline,
            maxLines: 3,
            minLines: 2,
            validator: AppValidators.validateSymptoms,
            decoration: const InputDecoration(
              labelText: 'Symptoms / Reason for Visit *',
              hintText: 'Describe your symptoms, duration or primary concern...',
              prefixIcon: Padding(
                padding: EdgeInsets.only(bottom: 30),
                child: Icon(Icons.notes_rounded),
              ),
              alignLabelWithHint: true,
            ),
          ),
          const SizedBox(height: 24),

          // 4. Submit Button
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              key: const Key('proceed_booking_button'),
              onPressed: _handleSubmit,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: const Text(
                'Review & Confirm Booking',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
