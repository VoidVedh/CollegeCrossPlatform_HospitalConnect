import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/app.dart';

void main() {
  testWidgets('HospitalConnectApp loads smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const HospitalConnectApp());
    expect(find.text('HospitalConnect'), findsOneWidget);
    expect(find.text('Step 01: Setup Complete'), findsOneWidget);
  });
}
