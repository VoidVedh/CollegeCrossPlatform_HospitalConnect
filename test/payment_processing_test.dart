import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/core/theme/app_theme.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/bill_provider.dart';
import 'package:hospital_connect/screens/billing/billing_screen.dart';
import 'package:hospital_connect/screens/payment/payment_screen.dart';
import 'package:hospital_connect/services/repositories/bill_repository.dart';
import 'package:hospital_connect/services/repositories/payment_gateway.dart';
import 'package:hospital_connect/widgets/payment_receipt_dialog.dart';
import 'package:provider/provider.dart';

class _FakeBillRepo implements BillRepository {
  _FakeBillRepo(List<BillModel> initial) : _bills = List.from(initial);
  final List<BillModel> _bills;

  @override
  Future<List<BillModel>> getBills() async => _bills;

  @override
  Future<BillModel?> getBillById(String id) async {
    try {
      return _bills.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

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
    final index = _bills.indexWhere((b) => b.id == billId);
    final updated = _bills[index].copyWith(
      status: status,
      paymentMethod: paymentMethod,
      paidAt: paidAt,
    );
    _bills[index] = updated;
    return updated;
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
      transactionId: 'TXN-SUCCESS-777',
      message: 'Transaction authorized.',
      paidAt: DateTime(2026, 9, 29, 15, 30),
    );
  }
}

void main() {
  final unpaidBill = BillModel(
    id: 'BIL-401',
    billDate: DateTime(2026, 9, 20),
    serviceName: 'Orthopedic Consultation',
    consultationFee: 900.0,
    labCharges: 400.0,
    tax: 234.0, // total = 1534.0
    status: BillStatus.unpaid,
  );

  final paidBill = BillModel(
    id: 'BIL-402',
    billDate: DateTime(2026, 9, 15),
    serviceName: 'Pediatric Health Check',
    consultationFee: 600.0,
    labCharges: 0.0,
    tax: 108.0, // total = 708.0
    status: BillStatus.paid,
    paymentMethod: PaymentMethodType.upi,
    paidAt: DateTime(2026, 9, 15, 11, 45),
  );

  test(
      'BillProvider.payBill updates bill status to paid, records method and timestamp',
      () async {
    final repo = _FakeBillRepo([unpaidBill]);
    final gateway = _InstantPaymentGateway();
    final provider = BillProvider(billRepository: repo, paymentGateway: gateway);
    await provider.loadBills();

    expect(provider.unpaidBillsCount, equals(1));
    expect(provider.bills.first.status, equals(BillStatus.unpaid));

    final result = await provider.payBill(
      billId: unpaidBill.id,
      method: PaymentMethodType.upi,
      details: {'upiId': 'patient@upi'},
    );

    expect(result.isSuccess, isTrue);
    expect(result.transactionId, equals('TXN-SUCCESS-777'));
    expect(provider.unpaidBillsCount, equals(0));

    final updated = provider.getBillById(unpaidBill.id);
    expect(updated, isNotNull);
    expect(updated!.status, equals(BillStatus.paid));
    expect(updated.paymentMethod, equals(PaymentMethodType.upi));
    expect(updated.paidAt, isNotNull);

    provider.dispose();
  });

  testWidgets(
      'PaymentReceiptDialog displays complete invoice details, charges, and actions',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light(useGoogleFonts: false),
        home: Scaffold(
          body: Builder(
            builder: (ctx) => Center(
              child: ElevatedButton(
                key: const Key('open_receipt_modal_btn'),
                onPressed: () => PaymentReceiptDialog.show(
                  ctx,
                  bill: paidBill,
                  transactionId: 'TXN-MOCK-999',
                ),
                child: const Text('Open'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('open_receipt_modal_btn')));
    await tester.pumpAndSettle();

    // Verify receipt contents
    expect(find.text('Payment Receipt'), findsOneWidget);
    expect(find.text('RECEIPT / TAX INVOICE'), findsOneWidget);
    expect(find.text('BIL-402'), findsOneWidget);
    expect(find.text('TXN-MOCK-999'), findsOneWidget);
    expect(find.text('Pediatric Health Check'), findsOneWidget);
    expect(find.byKey(const Key('receipt_total_amount_text')), findsOneWidget);
    expect(find.text('₹708'), findsWidgets);

    // Test download button action
    await tester.tap(find.byKey(const Key('download_receipt_button')));
    await tester.pumpAndSettle();
    expect(find.text('Receipt saved to Downloads/Receipt_BIL-402.pdf'),
        findsOneWidget);

    // Test close button
    await tester.tap(find.byKey(const Key('close_receipt_button')));
    await tester.pumpAndSettle();
    expect(find.text('Payment Receipt'), findsNothing);
  });

  testWidgets(
      'BillingScreen paid bills feature View Payment Receipt button which opens receipt',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = _FakeBillRepo([paidBill]);
    final provider =
        BillProvider(billRepository: repo, paymentGateway: _InstantPaymentGateway());

    await tester.pumpWidget(
      ChangeNotifierProvider<BillProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: const BillingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Verify Paid bill has View Payment Receipt button
    expect(find.byKey(Key('view_receipt_button_${paidBill.id}')), findsOneWidget);

    // Tap View Payment Receipt
    await tester.tap(find.byKey(Key('view_receipt_button_${paidBill.id}')));
    await tester.pumpAndSettle();

    expect(find.text('Payment Receipt'), findsOneWidget);
    expect(find.text('BIL-402'), findsWidgets);
    expect(find.byType(PaymentReceiptDialog), findsOneWidget);

    provider.dispose();
  });

  testWidgets(
      'PaymentScreen process payment dialog transitions to receipt view',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final repo = _FakeBillRepo([unpaidBill]);
    final provider =
        BillProvider(billRepository: repo, paymentGateway: _InstantPaymentGateway());

    await tester.pumpWidget(
      ChangeNotifierProvider<BillProvider>.value(
        value: provider,
        child: MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: PaymentScreen(bill: unpaidBill),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Tap Pay Securely
    await tester.tap(find.byKey(const Key('pay_securely_button')));
    await tester.pump(); // Displays processing dialog
    await tester.pump(const Duration(milliseconds: 100)); // Completes
    await tester.pumpAndSettle();

    // Verify Success modal
    expect(find.text('Payment Successful!'), findsOneWidget);
    expect(find.byKey(const Key('view_full_receipt_button')), findsOneWidget);

    // Tap View Full Tax Invoice & Receipt
    await tester.tap(find.byKey(const Key('view_full_receipt_button')));
    await tester.pumpAndSettle();

    expect(find.text('Payment Receipt'), findsOneWidget);
    expect(find.text('BIL-401'), findsWidgets);
    expect(find.byType(PaymentReceiptDialog), findsOneWidget);

    provider.dispose();
  });
}
