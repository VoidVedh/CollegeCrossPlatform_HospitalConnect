import 'package:flutter/foundation.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/services/repositories/repositories.dart';

/// State management provider for invoices, itemized billing, and simulated payment gateway execution.
class BillProvider extends ChangeNotifier {
  BillProvider({
    required this.billRepository,
    required this.paymentGateway,
  }) {
    loadBills();
  }

  final BillRepository billRepository;
  final PaymentGateway paymentGateway;

  List<BillModel> _bills = <BillModel>[];
  bool _isLoading = false;
  bool _isProcessingPayment = false;
  String? _error;
  PaymentResult? _lastPaymentResult;

  List<BillModel> get bills => List.unmodifiable(_bills);
  bool get isLoading => _isLoading;
  bool get isProcessingPayment => _isProcessingPayment;
  String? get error => _error;
  PaymentResult? get lastPaymentResult => _lastPaymentResult;

  /// Returns count of unpaid or pending bills for the NavigationBar badge.
  int get unpaidBillsCount =>
      _bills.where((b) => b.status != BillStatus.paid).length;

  List<BillModel> get unpaidBills =>
      _bills.where((b) => b.status != BillStatus.paid).toList();

  List<BillModel> get paidBills =>
      _bills.where((b) => b.status == BillStatus.paid).toList();

  Future<void> loadBills() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _bills = await billRepository.getBills();
    } catch (e) {
      _error = 'Failed to load bills: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  BillModel? getBillById(String id) {
    try {
      return _bills.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  /// Appends a newly created bill (e.g. consultation fee bill when booking an appointment).
  Future<BillModel> addBill(BillModel bill) async {
    final added = await billRepository.addBill(bill);
    _bills.insert(0, added);
    notifyListeners();
    return added;
  }

  /// Executes payment processing through the payment gateway and marks bill as paid.
  Future<PaymentResult> payBill({
    required String billId,
    required PaymentMethodType method,
    required Map<String, String> details,
  }) async {
    final bill = getBillById(billId);
    if (bill == null) {
      const result = PaymentResult(
        isSuccess: false,
        transactionId: '',
        message: 'Bill not found.',
      );
      _lastPaymentResult = result;
      return result;
    }

    _isProcessingPayment = true;
    _error = null;
    notifyListeners();

    try {
      final result = await paymentGateway.processPayment(
        billId: billId,
        amount: bill.totalAmount,
        method: method,
        details: details,
      );

      _lastPaymentResult = result;

      if (result.isSuccess) {
        final updatedBill = await billRepository.updateBillStatus(
          billId: billId,
          status: BillStatus.paid,
          paymentMethod: method,
          paidAt: result.paidAt ?? DateTime.now(),
        );

        final index = _bills.indexWhere((b) => b.id == billId);
        if (index != -1) {
          _bills[index] = updatedBill;
        }
      }

      return result;
    } catch (e) {
      final fail = PaymentResult(
        isSuccess: false,
        transactionId: '',
        message: 'Payment failed: $e',
      );
      _lastPaymentResult = fail;
      return fail;
    } finally {
      _isProcessingPayment = false;
      notifyListeners();
    }
  }
}
