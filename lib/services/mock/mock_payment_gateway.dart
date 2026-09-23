import 'package:hospital_connect/models/enums.dart';
import 'package:hospital_connect/services/repositories/payment_gateway.dart';
import 'package:uuid/uuid.dart';

/// Mock payment gateway simulating real-world gateway responses.
class MockPaymentGateway implements PaymentGateway {
  static const Uuid _uuid = Uuid();
  static const Duration _processingDelay = Duration(milliseconds: 600);

  @override
  Future<PaymentResult> processPayment({
    required String billId,
    required double amount,
    required PaymentMethodType method,
    required Map<String, String> details,
  }) async {
    await Future.delayed(_processingDelay);

    // Validate based on payment method
    switch (method) {
      case PaymentMethodType.upi:
        final upiId = details['upiId'] ?? '';
        if (!upiId.contains('@')) {
          return const PaymentResult(
            isSuccess: false,
            transactionId: '',
            message: 'Invalid UPI ID format.',
          );
        }
        break;
      case PaymentMethodType.card:
        final cardNumber = details['cardNumber'] ?? '';
        if (cardNumber.replaceAll(RegExp(r'\s+'), '').length < 16) {
          return const PaymentResult(
            isSuccess: false,
            transactionId: '',
            message: 'Invalid card number details.',
          );
        }
        break;
      case PaymentMethodType.netBanking:
        final bankName = details['bankName'] ?? '';
        if (bankName.isEmpty) {
          return const PaymentResult(
            isSuccess: false,
            transactionId: '',
            message: 'Please select your bank.',
          );
        }
        break;
    }

    final txId = 'TXN-${_uuid.v4().substring(0, 8).toUpperCase()}';
    return PaymentResult(
      isSuccess: true,
      transactionId: txId,
      message: 'Payment of ₹${amount.toStringAsFixed(2)} completed successfully.',
      paidAt: DateTime.now(),
    );
  }
}
