import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/core/theme/app_theme.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/bill_provider.dart';
import 'package:hospital_connect/screens/payment/payment_screen.dart';
import 'package:hospital_connect/services/repositories/bill_repository.dart';
import 'package:hospital_connect/services/repositories/payment_gateway.dart';
import 'package:provider/provider.dart';

class _FakeBillRepo implements BillRepository {
  final List<BillModel> _bills = [];
  @override
  Future<List<BillModel>> getBills() async => _bills;
  @override
  Future<BillModel?> getBillById(String id) async =>
      _bills.firstWhere((b) => b.id == id);
  @override
  Future<BillModel> addBill(BillModel bill) async {
    _bills.insert(0, bill);
    return bill;
  }

  @override
  Future<BillModel> updateBillStatus({
    required String billId,
    required BillStatus status,
    PaymentMethodType? paymentMethod,
    DateTime? paidAt,
  }) async {
    final idx = _bills.indexWhere((b) => b.id == billId);
    final updated = _bills[idx].copyWith(
      status: status,
      paymentMethod: paymentMethod,
      paidAt: paidAt,
    );
    _bills[idx] = updated;
    return updated;
  }

  @override
  Future<bool> removeBill(String id) async {
    _bills.removeWhere((b) => b.id == id);
    return true;
  }
}

class _InstantPaymentGateway implements PaymentGateway {
  @override
  Future<PaymentResult> processPayment({
    required String billId,
    required double amount,
    required PaymentMethodType method,
    required Map<String, String> details,
  }) async {
    return PaymentResult(
      isSuccess: true,
      transactionId: 'TXN-TEST-1234',
      message: 'Payment completed successfully.',
      paidAt: DateTime(2026, 9, 29, 14, 0),
    );
  }
}

void main() {
  final sampleBill = BillModel(
    id: 'BIL-999',
    billDate: DateTime(2026, 9, 25),
    serviceName: 'Neurology Consultation',
    consultationFee: 1200.0,
    labCharges: 300.0,
    tax: 270.0, // total: 1770.0
    status: BillStatus.unpaid,
  );

  Widget createTestWidget(BillProvider provider) {
    return ChangeNotifierProvider<BillProvider>.value(
      value: provider,
      child: MaterialApp(
        theme: AppTheme.light(useGoogleFonts: false),
        home: PaymentScreen(bill: sampleBill),
      ),
    );
  }

  testWidgets(
      'PaymentScreen renders bill summary, allows switching methods, and validates inputs',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = _FakeBillRepo();
    await repo.addBill(sampleBill);

    final provider = BillProvider(
      billRepository: repo,
      paymentGateway: _InstantPaymentGateway(),
    );

    await tester.pumpWidget(createTestWidget(provider));
    await tester.pumpAndSettle();

    // 1. Verify bill summary
    expect(find.text('Payment Gateway'), findsOneWidget);
    expect(find.text('BIL-999'), findsOneWidget);
    expect(find.text('Neurology Consultation'), findsOneWidget);
    expect(find.text('₹1,770'), findsWidgets);

    // 2. Verify payment method tabs
    expect(find.byKey(const Key('payment_tab_upi')), findsOneWidget);
    expect(find.byKey(const Key('payment_tab_card')), findsOneWidget);
    expect(find.byKey(const Key('payment_tab_net_banking')), findsOneWidget);

    // 3. Test UPI form default
    expect(find.byKey(const Key('upi_id_input_field')), findsOneWidget);
    expect(find.text('Google Pay'), findsOneWidget);

    // Tap PhonePe chip
    await tester.tap(find.text('PhonePe'));
    await tester.pumpAndSettle();

    // Verify UPI input updated with @ybl
    final upiField = tester.widget<TextFormField>(
      find.byKey(const Key('upi_id_input_field')),
    );
    expect(upiField.controller!.text, contains('@ybl'));

    // Clear UPI to test validation error
    await tester.enterText(find.byKey(const Key('upi_id_input_field')), '');
    await tester.tap(find.byKey(const Key('pay_securely_button')));
    await tester.pumpAndSettle();
    expect(find.text('UPI ID is required'), findsOneWidget);

    // 4. Test Card Method Tab
    await tester.tap(find.byKey(const Key('payment_tab_card')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('card_number_input_field')), findsOneWidget);
    expect(find.byKey(const Key('card_holder_input_field')), findsOneWidget);
    expect(find.byKey(const Key('card_expiry_input_field')), findsOneWidget);
    expect(find.byKey(const Key('card_cvv_input_field')), findsOneWidget);

    // Test card invalid validation
    await tester.enterText(
        find.byKey(const Key('card_number_input_field')), '1234');
    await tester.tap(find.byKey(const Key('pay_securely_button')));
    await tester.pumpAndSettle();
    expect(find.text('Card number must be 16 digits'), findsOneWidget);

    // 5. Test Net Banking Method Tab
    await tester.tap(find.byKey(const Key('payment_tab_net_banking')));
    await tester.pumpAndSettle();

    expect(find.text('Select Your Bank'), findsOneWidget);
    expect(find.byKey(const Key('bank_chip_HDFC Bank')), findsOneWidget);

    // Select HDFC Bank
    await tester.tap(find.byKey(const Key('bank_chip_HDFC Bank')));
    await tester.pumpAndSettle();

    // 6. Execute successful Net Banking payment
    await tester.tap(find.byKey(const Key('pay_securely_button')));
    await tester.pump(); // Show processing dialog
    await tester.pump(const Duration(milliseconds: 100)); // Process
    await tester.pumpAndSettle(); // Settle sheet

    // Verify Success Modal appears
    expect(find.text('Payment Successful!'), findsOneWidget);
    expect(find.text('TXN-TEST-1234'), findsOneWidget);
    expect(find.text('Your hospital bill has been settled.'), findsOneWidget);

    // Tap Done
    await tester.tap(find.byKey(const Key('return_to_billing_button')));
    await tester.pumpAndSettle();

    provider.dispose();
  });
}
