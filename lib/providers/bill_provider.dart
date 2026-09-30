import 'package:flutter/foundation.dart';
import 'package:hospital_connect/core/errors/app_exceptions.dart';
import 'package:hospital_connect/core/utils/safe_notifier.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/services/repositories/repositories.dart';
import 'package:uuid/uuid.dart';

/// State management provider for invoices, itemized billing, and simulated payment gateway execution.
class BillProvider extends ChangeNotifier with SafeNotifier {
  BillProvider({
    required this.billRepository,
    required this.paymentGateway,
  }) {
    loadBills();
  }

  final BillRepository billRepository;
  final PaymentGateway paymentGateway;
  static const Uuid _uuid = Uuid();

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
  /// Cancelled and paid bills are excluded.
  int get unpaidBillsCount => _bills
      .where((b) => b.status == BillStatus.unpaid || b.status == BillStatus.pending)
      .length;

  List<BillModel> get unpaidBills => _bills
      .where((b) => b.status == BillStatus.unpaid || b.status == BillStatus.pending)
      .toList();

  List<BillModel> get paidBills =>
      _bills.where((b) => b.status == BillStatus.paid).toList();

  List<BillModel> get cancelledBills =>
      _bills.where((b) => b.status == BillStatus.cancelled).toList();

  /// Collision-safe bill ID generator.
  static String generateUniqueBillId(Iterable<String> existingIds) {
    final existingSet = existingIds.toSet();
    for (int attempt = 0; attempt < 50; attempt++) {
      final randomSuffix = _uuid.v4().substring(0, 6).toUpperCase();
      final id = 'BIL-$randomSuffix';
      if (!existingSet.contains(id)) return id;
    }
    return 'BIL-${DateTime.now().microsecondsSinceEpoch.toRadixString(36).toUpperCase()}';
  }

  Future<void> loadBills() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loaded = await billRepository.getBills();
      if (isDisposed) return;
      _bills = List<BillModel>.from(loaded);
    } catch (e) {
      if (kDebugMode) {
        debugPrint('BillProvider loadBills error: $e');
      }
      _error = e is AppException
          ? e.userFriendlyMessage
          : 'Failed to load billing records. Please check connection and retry.';
    } finally {
      if (!isDisposed) {
        _isLoading = false;
        notifyListeners();
      }
    }
  }

  BillModel? getBillById(String id) {
    try {
      return _bills.firstWhere((b) => b.id == id);
    } on StateError {
      return null;
    }
  }

  /// Appends a newly created bill (e.g. consultation fee bill when booking an appointment).
  Future<BillModel> addBill(BillModel bill) async {
    final added = await billRepository.addBill(bill);
    if (isDisposed) return added;
    _bills.insert(0, added);
    notifyListeners();
    return added;
  }

  /// Voids or cancels a bill (e.g. when linked appointment is cancelled).
  Future<BillModel?> cancelBill(String billId) async {
    final bill = getBillById(billId);
    if (bill == null || bill.status == BillStatus.paid) return null;

    final updated = await billRepository.updateBillStatus(
      billId: billId,
      status: BillStatus.cancelled,
    );
    if (isDisposed) return updated;
    final index = _bills.indexWhere((b) => b.id == billId);
    if (index != -1) {
      _bills[index] = updated;
    }
    notifyListeners();
    return updated;
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
        message: 'Invoice not found.',
      );
      _lastPaymentResult = result;
      return result;
    }

    if (bill.status == BillStatus.cancelled) {
      const result = PaymentResult(
        isSuccess: false,
        transactionId: '',
        message: 'Cannot pay a cancelled invoice.',
      );
      _lastPaymentResult = result;
      return result;
    }

    if (bill.status == BillStatus.paid) {
      const result = PaymentResult(
        isSuccess: false,
        transactionId: '',
        message: 'This invoice has already been settled.',
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

      if (isDisposed) return result;
      _lastPaymentResult = result;

      if (result.isSuccess) {
        final updatedBill = await billRepository.updateBillStatus(
          billId: billId,
          status: BillStatus.paid,
          paymentMethod: method,
          paidAt: result.paidAt ?? DateTime.now(),
        );

        if (!isDisposed) {
          final index = _bills.indexWhere((b) => b.id == billId);
          if (index != -1) {
            _bills[index] = updatedBill;
          }
        }
      }

      return result;
    } catch (e) {
      if (kDebugMode) {
        debugPrint('BillProvider payBill error: $e');
      }
      final fail = PaymentResult(
        isSuccess: false,
        transactionId: '',
        message: e is AppException
            ? e.userFriendlyMessage
            : 'Payment transaction failed. Please retry.',
      );
      _lastPaymentResult = fail;
      return fail;
    } finally {
      if (!isDisposed) {
        _isProcessingPayment = false;
        notifyListeners();
      }
    }
  }
}
