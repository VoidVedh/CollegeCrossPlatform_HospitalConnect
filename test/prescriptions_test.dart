import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/core/theme/app_theme.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/prescription_provider.dart';
import 'package:hospital_connect/screens/prescriptions/prescriptions_screen.dart';
import 'package:hospital_connect/services/repositories/prescription_repository.dart';
import 'package:hospital_connect/widgets/prescription_preview_modal.dart';
import 'package:provider/provider.dart';

class _FakePrescriptionRepository implements PrescriptionRepository {
  _FakePrescriptionRepository(this._prescriptions);
  final List<PrescriptionModel> _prescriptions;

  @override
  Future<List<PrescriptionModel>> getPrescriptions() async => _prescriptions;

  @override
  Future<PrescriptionModel?> getPrescriptionById(String id) async {
    try {
      return _prescriptions.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }
}

void main() {
  final samplePrescriptions = [
    PrescriptionModel(
      id: 'RX-701',
      doctorName: 'Dr. Rajesh Sharma',
      issueDate: DateTime(2026, 9, 10),
      diagnosis: 'Stage 1 Essential Hypertension',
      medications: const [
        MedicationModel(
          name: 'Telmisartan Tablets',
          dosage: '40 mg',
          frequency: 'Once daily (Morning)',
          duration: '30 Days',
        ),
        MedicationModel(
          name: 'Amlodipine Tablets',
          dosage: '5 mg',
          frequency: 'Once daily (Night)',
          duration: '30 Days',
        ),
      ],
      instructions: 'Limit sodium intake. Log blood pressure daily.',
    ),
  ];

  testWidgets(
      'PrescriptionsScreen renders prescriptions and opens printable preview modal',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final provider =
        PrescriptionProvider(_FakePrescriptionRepository(samplePrescriptions));

    await tester.pumpWidget(
      ChangeNotifierProvider<PrescriptionProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: const PrescriptionsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify card content
    expect(find.text('My Prescriptions'), findsOneWidget);
    expect(find.text('RX-701'), findsOneWidget);
    expect(find.text('Stage 1 Essential Hypertension'), findsOneWidget);
    expect(find.text('Dr. Rajesh Sharma'), findsOneWidget);
    expect(find.text('2 Prescribed Medications'), findsOneWidget);

    // Expand medication details
    await tester.tap(find.text('2 Prescribed Medications'));
    await tester.pumpAndSettle();

    expect(find.text('Telmisartan Tablets'), findsOneWidget);
    expect(find.text('40 mg'), findsOneWidget);
    expect(find.text('Amlodipine Tablets'), findsOneWidget);

    // Tap View & Print button to open modal
    await tester.tap(find.byKey(const Key('print_rx_card_RX-701')));
    await tester.pumpAndSettle();

    // Verify PrescriptionPreviewModal contents
    expect(find.byType(PrescriptionPreviewModal), findsOneWidget);
    expect(find.text('HospitalConnect Health'), findsOneWidget);
    expect(find.text('℞ Prescribed Medications'), findsOneWidget);
    expect(find.byKey(const Key('print_prescription_modal_button')), findsOneWidget);

    // Tap Print Document button
    await tester.tap(find.byKey(const Key('print_prescription_modal_button')));
    await tester.pump();

    expect(
      find.text('Prescription sent to printer (Offline simulation)'),
      findsOneWidget,
    );

    provider.dispose();
  });

  testWidgets('PrescriptionsScreen renders empty state when no prescriptions',
      (tester) async {
    final emptyProvider =
        PrescriptionProvider(_FakePrescriptionRepository([]));

    await tester.pumpWidget(
      ChangeNotifierProvider<PrescriptionProvider>.value(
        value: emptyProvider,
        child: MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: const PrescriptionsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No Prescriptions Available'), findsOneWidget);
    emptyProvider.dispose();
  });
}
