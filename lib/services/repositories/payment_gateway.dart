import 'package:hospital_connect/models/enums.dart';

/// Result object returned by the payment gateway.
class PaymentResult {
  const PaymentResult({
    required this.isSuccess,
    required this.transactionId,
    required this.message,
    this.paidAt,
  });

  final bool isSuccess;
  final String transactionId;
  final String message;
  final DateTime? paidAt;
}

/// Abstract payment gateway interface supporting UPI, Cards, and Net Banking.
abstract class PaymentGateway {
  /// Processes payment simulation for an unpaid or pending bill.
  Future<PaymentResult> processPayment({
    required String billId,
    required double amount,
    required PaymentMethodType method,
    required Map<String, String> details,
  });
}
