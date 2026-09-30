import 'package:hospital_connect/models/enums.dart';
import 'package:hospital_connect/services/repositories/payment_gateway.dart';
import 'package:uuid/uuid.dart';

/// Mock payment gateway simulating real-world gateway responses with failure triggers.
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

    // Validate based on payment method and check simulated failure triggers
    switch (method) {
      case PaymentMethodType.upi:
        final upiId = (details['upiId'] ?? '').trim().toLowerCase();
        if (!upiId.contains('@')) {
          return const PaymentResult(
            isSuccess: false,
            transactionId: '',
            message: 'Invalid UPI ID format. Expected user@bank',
          );
        }
        if (upiId.contains('fail') || upiId.contains('decline')) {
          return const PaymentResult(
            isSuccess: false,
            transactionId: '',
            message: 'UPI payment declined by bank: Insufficient funds or server timeout.',
          );
        }
        break;

      case PaymentMethodType.card:
        final cleanNumber = (details['cardNumber'] ?? '').replaceAll(RegExp(r'\s+'), '');
        final cardHolder = (details['cardHolder'] ?? '').toUpperCase();
        if (cleanNumber.length < 15) {
          return const PaymentResult(
            isSuccess: false,
            transactionId: '',
            message: 'Invalid card number details.',
          );
        }
        if (cleanNumber.endsWith('0002') || cardHolder.contains('FAIL') || cardHolder.contains('DECLINE')) {
          return const PaymentResult(
            isSuccess: false,
            transactionId: '',
            message: 'Card declined: Transaction denied by issuing bank (Simulated Failure).',
          );
        }
        break;

      case PaymentMethodType.netBanking:
        final bankName = (details['bankName'] ?? '').trim();
        if (bankName.isEmpty) {
          return const PaymentResult(
            isSuccess: false,
            transactionId: '',
            message: 'Please select your bank.',
          );
        }
        if (bankName.toLowerCase().contains('fail')) {
          return const PaymentResult(
            isSuccess: false,
            transactionId: '',
            message: 'Bank gateway timeout: Transaction declined by bank server.',
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
