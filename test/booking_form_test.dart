import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/core/theme/app_theme.dart';
import 'package:hospital_connect/widgets/patient_booking_form.dart';

void main() {
  Widget buildTestableForm({
    required bool isSlotSelected,
    required PatientBookingCallback onSubmit,
    VoidCallback? onSlotNeeded,
  }) {
    return MaterialApp(
      theme: AppTheme.light(useGoogleFonts: false),
      home: Scaffold(
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: PatientBookingForm(
              isSlotSelected: isSlotSelected,
              onSubmit: onSubmit,
              onSlotNeeded: onSlotNeeded,
            ),
          ),
        ),
      ),
    );
  }

  testWidgets('PatientBookingForm enforces validation on all fields',
      (tester) async {
    bool submitted = false;

    await tester.pumpWidget(
      buildTestableForm(
        isSlotSelected: true,
        onSubmit: ({
          required patientName,
          required patientAge,
          required patientPhone,
          required symptomsNote,
        }) {
          submitted = true;
        },
      ),
    );
    await tester.pumpAndSettle();

    // Tap submit with empty fields
    await tester.tap(find.byKey(const Key('proceed_booking_button')));
    await tester.pumpAndSettle();

    // Validation errors should appear
    expect(find.text('Patient name is required'), findsOneWidget);
    expect(find.text('Age is required'), findsOneWidget);
    expect(find.text('Phone number is required'), findsOneWidget);
    expect(
      find.text('Please describe symptoms or reason for visit'),
      findsOneWidget,
    );
    expect(submitted, isFalse);
  });

  testWidgets('PatientBookingForm blocks submission if slot is not selected',
      (tester) async {
    bool submitted = false;
    bool slotNeededTriggered = false;

    await tester.pumpWidget(
      buildTestableForm(
        isSlotSelected: false,
        onSlotNeeded: () => slotNeededTriggered = true,
        onSubmit: ({
          required patientName,
          required patientAge,
          required patientPhone,
          required symptomsNote,
        }) {
          submitted = true;
        },
      ),
    );
    await tester.pumpAndSettle();

    // Fill valid info
    await tester.enterText(
      find.byKey(const Key('patient_name_field')),
      'Sunil Verma',
    );
    await tester.enterText(find.byKey(const Key('patient_age_field')), '34');
    await tester.enterText(
      find.byKey(const Key('patient_phone_field')),
      '9876543210',
    );
    await tester.enterText(
      find.byKey(const Key('patient_symptoms_field')),
      'High fever and chest pain since 2 days',
    );
    await tester.pumpAndSettle();

    // Tap submit
    await tester.tap(find.byKey(const Key('proceed_booking_button')));
    await tester.pump();

    expect(submitted, isFalse);
    expect(slotNeededTriggered, isTrue);
    expect(
      find.text('Please select an appointment time slot above.'),
      findsOneWidget,
    );
  });

  testWidgets(
      'PatientBookingForm successfully submits when slot and inputs are valid',
      (tester) async {
    String? submittedName;
    int? submittedAge;
    String? submittedPhone;
    String? submittedSymptoms;

    await tester.pumpWidget(
      buildTestableForm(
        isSlotSelected: true,
        onSubmit: ({
          required patientName,
          required patientAge,
          required patientPhone,
          required symptomsNote,
        }) {
          submittedName = patientName;
          submittedAge = patientAge;
          submittedPhone = patientPhone;
          submittedSymptoms = symptomsNote;
        },
      ),
    );
    await tester.pumpAndSettle();

    // Fill valid inputs
    await tester.enterText(
      find.byKey(const Key('patient_name_field')),
      'Priya Sharma',
    );
    await tester.enterText(find.byKey(const Key('patient_age_field')), '29');
    await tester.enterText(
      find.byKey(const Key('patient_phone_field')),
      '9811223344',
    );
    await tester.enterText(
      find.byKey(const Key('patient_symptoms_field')),
      'Persistent migraine headache and sensitivity to light',
    );
    await tester.pumpAndSettle();

    // Tap submit
    await tester.tap(find.byKey(const Key('proceed_booking_button')));
    await tester.pumpAndSettle();

    expect(submittedName, equals('Priya Sharma'));
    expect(submittedAge, equals(29));
    expect(submittedPhone, equals('9811223344'));
    expect(
      submittedSymptoms,
      equals('Persistent migraine headache and sensitivity to light'),
    );
  });
}
