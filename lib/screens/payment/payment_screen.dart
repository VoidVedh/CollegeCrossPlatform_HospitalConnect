import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/bill_provider.dart';
import 'package:hospital_connect/screens/payment/widgets/bill_summary_card.dart';
import 'package:hospital_connect/screens/payment/widgets/card_payment_form.dart';
import 'package:hospital_connect/screens/payment/widgets/netbanking_form.dart';
import 'package:hospital_connect/screens/payment/widgets/payment_method_tabs.dart';
import 'package:hospital_connect/screens/payment/widgets/payment_processing_dialog.dart';
import 'package:hospital_connect/screens/payment/widgets/payment_security_badges.dart';
import 'package:hospital_connect/screens/payment/widgets/payment_success_sheet.dart';
import 'package:hospital_connect/screens/payment/widgets/upi_payment_form.dart';
import 'package:provider/provider.dart';

/// Simulated Payment Gateway Screen offering UPI, Cards, and Net Banking options.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    this.bill,
    this.billId,
    this.onPaymentSuccess,
  }) : assert(bill != null || billId != null, 'Either bill or billId must be provided');

  final BillModel? bill;
  final String? billId;
  final VoidCallback? onPaymentSuccess;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethodType _selectedMethod = PaymentMethodType.upi;

  final GlobalKey<FormState> _upiFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _cardFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _netBankingFormKey = GlobalKey<FormState>();

  final TextEditingController _upiController =
      TextEditingController(text: 'aditya.sharma@okhdfcbank');

  final TextEditingController _cardNumberController =
      TextEditingController(text: '4532 8901 2345 6789');
  final TextEditingController _cardHolderController =
      TextEditingController(text: 'Aditya Sharma');
  final TextEditingController _cardExpiryController =
      TextEditingController(text: '08/28');
  final TextEditingController _cardCvvController =
      TextEditingController(text: '321');
  bool _obscureCvv = true;

  String _selectedBank = 'State Bank of India (SBI)';

  final List<String> _popularBanks = const [
    'State Bank of India (SBI)',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Punjab National Bank (PNB)',
    'Kotak Mahindra Bank',
  ];

  final List<String> _allBanks = const [
    'State Bank of India (SBI)',
    'HDFC Bank',
    'ICICI Bank',
    'Axis Bank',
    'Punjab National Bank (PNB)',
    'Kotak Mahindra Bank',
    'Bank of Baroda',
    'Canara Bank',
    'Union Bank of India',
    'IndusInd Bank',
    'Yes Bank',
    'Federal Bank',
    'IDFC FIRST Bank',
  ];

  @override
  void dispose() {
    _upiController.dispose();
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _cardExpiryController.dispose();
    _cardCvvController.dispose();
    super.dispose();
  }

  void _handlePay() {
    Map<String, String> details = {};

    switch (_selectedMethod) {
      case PaymentMethodType.upi:
        if (!_upiFormKey.currentState!.validate()) return;
        details = {'upiId': _upiController.text.trim()};
        break;

      case PaymentMethodType.card:
        if (!_cardFormKey.currentState!.validate()) return;
        details = {
          'cardNumber':
              _cardNumberController.text.replaceAll(RegExp(r'\s+'), ''),
          'cardHolder': _cardHolderController.text.trim(),
          'cardExpiry': _cardExpiryController.text.trim(),
          'cardCvv': _cardCvvController.text.trim(),
        };
        break;

      case PaymentMethodType.netBanking:
        if (!_netBankingFormKey.currentState!.validate()) return;
        details = {'bankName': _selectedBank};
        break;
    }

    _processPaymentExecution(details);
  }

  BillModel? _resolveBill(BuildContext context) {
    final provider = context.read<BillProvider>();
    final targetId = widget.billId ?? widget.bill?.id;
    if (targetId != null) {
      final fromProvider = provider.getBillById(targetId);
      if (fromProvider != null) return fromProvider;
    }
    return widget.bill;
  }

  Future<void> _processPaymentExecution(Map<String, String> details) async {
    final provider = context.read<BillProvider>();
    final bill = _resolveBill(context);
    if (bill == null) return;

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) => PaymentProcessingDialog(bill: bill),
    );

    final result = await provider.payBill(
      billId: bill.id,
      method: _selectedMethod,
      details: details,
    );

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Close processing dialog

    if (result.isSuccess) {
      widget.onPaymentSuccess?.call();
      PaymentSuccessSheet.show(
        context,
        bill: _resolveBill(context) ?? widget.bill!,
        result: result,
        selectedMethod: _selectedMethod,
        onDone: () {
          Navigator.of(context).pop(); // Dismiss sheet
          Navigator.of(context).pop(); // Return to previous screen
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result.message),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Widget _buildSelectedMethodForm() {
    switch (_selectedMethod) {
      case PaymentMethodType.upi:
        return UpiPaymentForm(
          formKey: _upiFormKey,
          controller: _upiController,
          onHandleSelected: (handle) {
            final current = _upiController.text.trim();
            final username =
                current.contains('@') ? current.split('@').first : 'user';
            setState(() => _upiController.text = '$username$handle');
          },
        );
      case PaymentMethodType.card:
        return CardPaymentForm(
          formKey: _cardFormKey,
          cardNumberController: _cardNumberController,
          cardHolderController: _cardHolderController,
          cardExpiryController: _cardExpiryController,
          cardCvvController: _cardCvvController,
          obscureCvv: _obscureCvv,
          onToggleObscureCvv: () => setState(() => _obscureCvv = !_obscureCvv),
        );
      case PaymentMethodType.netBanking:
        return NetbankingForm(
          formKey: _netBankingFormKey,
          selectedBank: _selectedBank,
          popularBanks: _popularBanks,
          allBanks: _allBanks,
          onBankSelected: (bank) => setState(() => _selectedBank = bank),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final billProvider = context.watch<BillProvider>();
    final targetId = widget.billId ?? widget.bill?.id;
    final activeBill = targetId != null ? billProvider.getBillById(targetId) : null;
    final bill = activeBill ?? widget.bill;

    if (bill == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Payment Gateway')),
        body: const Center(child: Text('Invoice details not found.')),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Payment Gateway')),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
              children: [
                BillSummaryCard(bill: bill),
                const SizedBox(height: AppSpacing.xl),
                Text(
                  'Select Payment Method',
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: AppSpacing.md),
                PaymentMethodTabs(
                  selectedMethod: _selectedMethod,
                  onMethodChanged: (method) => setState(() => _selectedMethod = method),
                ),
                const SizedBox(height: AppSpacing.xl),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildSelectedMethodForm(),
                ),
                const SizedBox(height: AppSpacing.xxl),
                const PaymentSecurityBadges(),
                const SizedBox(height: AppSpacing.xxl),
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    key: const Key('pay_securely_button'),
                    onPressed: _handlePay,
                    icon: const Icon(Icons.lock_rounded, size: 20),
                    label: Text(
                      'Pay ${AppFormatters.formatCurrency(bill.totalAmount)} Securely',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xxl),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
