import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/core/theme/app_theme.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/bill_provider.dart';
import 'package:hospital_connect/screens/billing/billing_screen.dart';
import 'package:hospital_connect/services/mock/mock_services.dart';
import 'package:hospital_connect/services/repositories/bill_repository.dart';
import 'package:provider/provider.dart';

class _FakeBillRepository implements BillRepository {
  _FakeBillRepository(this._bills);
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

void main() {
  test('BillModel.totalAmount correctly computes sum without hardcoding', () {
    final bill = BillModel(
      id: 'BIL-TEST',
      billDate: DateTime(2026, 9, 1),
      serviceName: 'Consultation',
      consultationFee: 750.0,
      labCharges: 250.0,
      tax: 180.0,
      status: BillStatus.unpaid,
    );

    expect(bill.totalAmount, equals(1180.0));
  });

  testWidgets(
      'BillingScreen displays dues metric, itemized breakdown, and status badges',
      (tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(() {
      tester.view.resetPhysicalSize();
      tester.view.resetDevicePixelRatio();
    });

    final testBills = [
      BillModel(
        id: 'BIL-101',
        billDate: DateTime(2026, 9, 20),
        serviceName: 'Cardiology Consultation',
        consultationFee: 800.0,
        labCharges: 200.0,
        tax: 180.0, // total = 1180.0
        status: BillStatus.pending,
      ),
      BillModel(
        id: 'BIL-102',
        billDate: DateTime(2026, 9, 10),
        serviceName: 'Pediatric Health Check',
        consultationFee: 600.0,
        labCharges: 0.0,
        tax: 108.0, // total = 708.0
        status: BillStatus.paid,
        paymentMethod: PaymentMethodType.upi,
        paidAt: DateTime(2026, 9, 10, 14, 30),
      ),
    ];

    final provider = BillProvider(
      billRepository: _FakeBillRepository(testBills),
      paymentGateway: MockPaymentGateway(),
    );

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

    // Verify Outstanding Dues banner displays ₹1,180
    expect(find.byKey(const Key('total_outstanding_dues_text')), findsOneWidget);
    expect(find.text('₹1,180'), findsWidgets);

    // Verify status badges
    expect(find.text('PENDING'), findsOneWidget);
    expect(find.text('PAID'), findsOneWidget);

    // Verify itemized charges on card
    expect(find.text('Doctor Consultation'), findsWidgets);
    expect(find.text('Applicable GST / Tax'), findsWidgets);

    // Filter by Paid History
    await tester.tap(find.text('Paid History (1)'));
    await tester.pumpAndSettle();

    expect(find.text('BIL-102'), findsOneWidget);
    expect(find.text('BIL-101'), findsNothing);

    // Switch back to All Bills
    await tester.tap(find.text('All Bills (2)'));
    await tester.pumpAndSettle();

    // Tap Pay Now on pending bill BIL-101
    await tester.tap(find.byKey(const Key('pay_bill_button_BIL-101')));
    await tester.pumpAndSettle();

    // Verify itemized summary bottom sheet opens
    expect(find.text('Itemized Bill Summary'), findsOneWidget);
    expect(find.text('Invoice Ref: BIL-101'), findsOneWidget);
    expect(find.byKey(const Key('proceed_payment_gateway_button')), findsOneWidget);

    // Tap proceed button
    await tester.tap(find.byKey(const Key('proceed_payment_gateway_button')));
    await tester.pump();

    provider.dispose();
  });

  testWidgets('BillingScreen displays empty state when no bills exist',
      (tester) async {
    final emptyProvider = BillProvider(
      billRepository: _FakeBillRepository([]),
      paymentGateway: MockPaymentGateway(),
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<BillProvider>.value(
        value: emptyProvider,
        child: MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: const BillingScreen(),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ALL DUES CLEARED'), findsOneWidget);
    expect(find.text('No Invoices Found'), findsOneWidget);

    emptyProvider.dispose();
  });
}
