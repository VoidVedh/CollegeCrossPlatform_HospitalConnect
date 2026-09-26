import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/core/theme/app_theme.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/medical_record_provider.dart';
import 'package:hospital_connect/screens/records/record_detail_screen.dart';
import 'package:hospital_connect/screens/records/records_screen.dart';
import 'package:hospital_connect/services/repositories/medical_record_repository.dart';
import 'package:provider/provider.dart';

class _FakeRecordRepository implements MedicalRecordRepository {
  _FakeRecordRepository(this._records);
  final List<MedicalRecordModel> _records;

  @override
  Future<List<MedicalRecordModel>> getMedicalRecords() async => _records;

  @override
  Future<MedicalRecordModel?> getRecordById(String id) async {
    try {
      return _records.firstWhere((r) => r.id == id);
    } catch (_) {
      return null;
    }
  }
}

void main() {
  final sampleRecords = [
    MedicalRecordModel(
      id: 'MR-501',
      diagnosis: 'Hypertension and Lipid Management',
      doctorName: 'Dr. Rajesh Sharma',
      visitDate: DateTime(2026, 8, 12),
      hospitalName: 'Fortis Hospital',
      summary:
          'Routine review for essential hypertension. Patient is asymptomatic. Blood pressure 128/82 mmHg.',
      attachments: const [
        RecordAttachmentModel(
          fileName: 'Lipid_Profile_Report.pdf',
          fileType: 'pdf',
        ),
      ],
    ),
    MedicalRecordModel(
      id: 'MR-502',
      diagnosis: 'Right Knee Meniscal Evaluation',
      doctorName: 'Dr. Arjun Nair',
      visitDate: DateTime(2026, 7, 5),
      hospitalName: 'Manipal Hospital',
      summary: 'Mild joint effusion noted on examination.',
      attachments: const [
        RecordAttachmentModel(
          fileName: 'Knee_Scan.jpg',
          fileType: 'jpg',
        ),
      ],
    ),
  ];

  testWidgets(
      'RecordsScreen renders medical history timeline and navigates to details',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final provider = MedicalRecordProvider(_FakeRecordRepository(sampleRecords));

    await tester.pumpWidget(
      ChangeNotifierProvider<MedicalRecordProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: const RecordsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify timeline header and records
    expect(find.text('Clinical Visit Timeline'), findsOneWidget);
    expect(find.text('Hypertension and Lipid Management'), findsOneWidget);
    expect(find.text('Dr. Rajesh Sharma • Fortis Hospital'), findsOneWidget);
    expect(find.text('1 Reports'), findsWidgets);

    // Tap on the first record to navigate to RecordDetailScreen
    await tester.tap(find.text('Hypertension and Lipid Management'));
    await tester.pumpAndSettle();

    // Verify RecordDetailScreen content
    expect(find.byType(RecordDetailScreen), findsOneWidget);
    expect(find.text('Clinical Summary & Observations'), findsOneWidget);
    expect(find.text('Diagnostic Reports & Scans'), findsOneWidget);
    expect(find.text('Lipid_Profile_Report.pdf'), findsOneWidget);

    // Tap on attachment download/preview button
    await tester.tap(find.byTooltip('View or Download Attachment'));
    await tester.pump();

    expect(
      find.text('Viewing Lipid_Profile_Report.pdf (Offline preview)'),
      findsOneWidget,
    );

    provider.dispose();
  });

  testWidgets('RecordsScreen displays empty state when no records exist',
      (tester) async {
    final emptyProvider = MedicalRecordProvider(_FakeRecordRepository([]));

    await tester.pumpWidget(
      ChangeNotifierProvider<MedicalRecordProvider>.value(
        value: emptyProvider,
        child: MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: const RecordsScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('No Medical Records Found'), findsOneWidget);
    emptyProvider.dispose();
  });
}
