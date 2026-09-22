import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/app.dart';

void main() {
  testWidgets('Theme preview screen loads', (WidgetTester tester) async {
    await tester.pumpWidget(const HospitalConnectApp(useGoogleFonts: false));

    expect(find.text('HospitalConnect'), findsOneWidget);
    expect(find.text('Healthcare Theme Preview'), findsOneWidget);
    expect(find.text('Upcoming'), findsOneWidget);
    expect(find.text('Unpaid'), findsOneWidget);
  });
}
