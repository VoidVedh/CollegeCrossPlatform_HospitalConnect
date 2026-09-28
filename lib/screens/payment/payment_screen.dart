import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/core/utils/validators.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/bill_provider.dart';
import 'package:hospital_connect/services/repositories/payment_gateway.dart';
import 'package:hospital_connect/widgets/payment_receipt_dialog.dart';
import 'package:provider/provider.dart';

/// Simulated Payment Gateway Screen offering UPI, Cards, and Net Banking options.
class PaymentScreen extends StatefulWidget {
  const PaymentScreen({
    super.key,
    required this.bill,
    this.onPaymentSuccess,
  });

  final BillModel bill;
  final VoidCallback? onPaymentSuccess;

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  PaymentMethodType _selectedMethod = PaymentMethodType.upi;

  final GlobalKey<FormState> _upiFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _cardFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _netBankingFormKey = GlobalKey<FormState>();

  // UPI controllers
  final TextEditingController _upiController =
      TextEditingController(text: 'aditya.sharma@okhdfcbank');

  // Card controllers
  final TextEditingController _cardNumberController =
      TextEditingController(text: '4532 8901 2345 6789');
  final TextEditingController _cardHolderController =
      TextEditingController(text: 'Aditya Sharma');
  final TextEditingController _cardExpiryController =
      TextEditingController(text: '08/28');
  final TextEditingController _cardCvvController =
      TextEditingController(text: '321');
  bool _obscureCvv = true;

  // Net banking selection
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

  Future<void> _processPaymentExecution(Map<String, String> details) async {
    // In Step 17 this validates inputs and performs payment through BillProvider
    final provider = context.read<BillProvider>();

    // Show processing indicator dialog
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogCtx) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            content: Padding(
              padding: const EdgeInsets.symmetric(vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 20),
                  Text(
                    'Contacting Payment Gateway...',
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Processing secure transaction of ${AppFormatters.formatCurrency(widget.bill.totalAmount)}',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    final result = await provider.payBill(
      billId: widget.bill.id,
      method: _selectedMethod,
      details: details,
    );

    if (!mounted) return;
    Navigator.of(context, rootNavigator: true).pop(); // Close processing dialog

    if (result.isSuccess) {
      widget.onPaymentSuccess?.call();
      _showPaymentSuccessModal(result);
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

  void _showPaymentSuccessModal(PaymentResult result) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        final theme = Theme.of(sheetContext);
        final colorScheme = theme.colorScheme;

        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(sheetContext).size.height * 0.85,
            maxWidth: 640,
          ),
          padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
          decoration: BoxDecoration(
            color: colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.statusCompleted,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Payment Successful!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.statusCompleted,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Your hospital bill has been settled.',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.4),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Column(
                  children: [
                    _receiptRow(
                      'Transaction ID',
                      result.transactionId,
                      theme,
                      isBold: true,
                    ),
                    const Divider(height: 16),
                    _receiptRow(
                      'Invoice ID',
                      widget.bill.id,
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _receiptRow(
                      'Service',
                      widget.bill.serviceName,
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _receiptRow(
                      'Amount Paid',
                      AppFormatters.formatCurrency(widget.bill.totalAmount),
                      theme,
                      isPrimary: true,
                    ),
                    const SizedBox(height: 8),
                    _receiptRow(
                      'Payment Method',
                      _selectedMethod.displayName,
                      theme,
                    ),
                    const SizedBox(height: 8),
                    _receiptRow(
                      'Date & Time',
                      AppFormatters.formatDateTime(
                        result.paidAt ?? DateTime.now(),
                      ),
                      theme,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: OutlinedButton.icon(
                  key: const Key('view_full_receipt_button'),
                  onPressed: () {
                    final updatedBill = context
                            .read<BillProvider>()
                            .getBillById(widget.bill.id) ??
                        widget.bill;
                    PaymentReceiptDialog.show(
                      sheetContext,
                      bill: updatedBill,
                      transactionId: result.transactionId,
                    );
                  },
                  icon: const Icon(Icons.receipt_long_rounded, size: 18),
                  label: const Text(
                    'View Full Tax Invoice & Receipt',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: FilledButton(
                  key: const Key('return_to_billing_button'),
                  onPressed: () {
                    Navigator.of(sheetContext).pop(); // Dismiss modal
                    Navigator.of(context).pop(); // Return to previous screen
                  },
                  child: const Text(
                    'Done',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _receiptRow(
    String label,
    String value,
    ThemeData theme, {
    bool isBold = false,
    bool isPrimary = false,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          value,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: isBold || isPrimary ? FontWeight.w700 : FontWeight.w500,
            color: isPrimary ? AppColors.primary : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payment Gateway'),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              children: [
                // 1. Bill Summary Card
                _buildBillSummaryCard(theme, colorScheme),
                const SizedBox(height: 20),

                // 2. Payment Method Selector Tabs
                Text(
                  'Select Payment Method',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 12),
                _buildMethodSelector(theme, colorScheme),
                const SizedBox(height: 20),

                // 3. Dynamic Method Form View
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: _buildSelectedMethodForm(theme, colorScheme),
                ),
                const SizedBox(height: 24),

                // 4. Security & Trust Badges
                _buildSecurityBadges(theme, colorScheme),
                const SizedBox(height: 24),

                // 5. Pay Securely Action Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: FilledButton.icon(
                    key: const Key('pay_securely_button'),
                    onPressed: _handlePay,
                    icon: const Icon(Icons.lock_rounded, size: 20),
                    label: Text(
                      'Pay ${AppFormatters.formatCurrency(widget.bill.totalAmount)} Securely',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBillSummaryCard(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: colorScheme.outlineVariant),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PAYABLE INVOICE',
                style: theme.textTheme.labelSmall?.copyWith(
                  letterSpacing: 1,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  widget.bill.id,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            widget.bill.serviceName,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Date: ${AppFormatters.formatDate(widget.bill.billDate)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              Text(
                AppFormatters.formatCurrency(widget.bill.totalAmount),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMethodSelector(ThemeData theme, ColorScheme colorScheme) {
    return Row(
      children: [
        Expanded(
          child: _methodTab(
            type: PaymentMethodType.upi,
            icon: Icons.qr_code_2_rounded,
            label: 'UPI',
            keyName: 'payment_tab_upi',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _methodTab(
            type: PaymentMethodType.card,
            icon: Icons.credit_card_rounded,
            label: 'Card',
            keyName: 'payment_tab_card',
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _methodTab(
            type: PaymentMethodType.netBanking,
            icon: Icons.account_balance_rounded,
            label: 'Net Banking',
            keyName: 'payment_tab_net_banking',
          ),
        ),
      ],
    );
  }

  Widget _methodTab({
    required PaymentMethodType type,
    required IconData icon,
    required String label,
    required String keyName,
  }) {
    final isSelected = _selectedMethod == type;
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label: 'Select $label payment method',
      button: true,
      selected: isSelected,
      child: InkWell(
        key: Key(keyName),
        onTap: () {
          setState(() {
            _selectedMethod = type;
          });
        },
        borderRadius: BorderRadius.circular(14),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryContainer
                : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: isSelected ? AppColors.primary : colorScheme.outlineVariant,
              width: isSelected ? 1.5 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color:
                    isSelected ? AppColors.primary : colorScheme.onSurfaceVariant,
                size: 24,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  color: isSelected ? AppColors.primary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSelectedMethodForm(ThemeData theme, ColorScheme colorScheme) {
    switch (_selectedMethod) {
      case PaymentMethodType.upi:
        return _buildUpiForm(theme, colorScheme);
      case PaymentMethodType.card:
        return _buildCardForm(theme, colorScheme);
      case PaymentMethodType.netBanking:
        return _buildNetBankingForm(theme, colorScheme);
    }
  }

  // --- 1. UPI FORM ---
  Widget _buildUpiForm(ThemeData theme, ColorScheme colorScheme) {
    return Form(
      key: _upiFormKey,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Unified Payments Interface (UPI)',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Pay directly from your bank account using your virtual payment address.',
              style: theme.textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('upi_id_input_field'),
              controller: _upiController,
              validator: AppValidators.validateUpiId,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'UPI ID / VPA',
                hintText: 'e.g. mobile@upi or username@okhdfcbank',
                prefixIcon: Icon(Icons.alternate_email_rounded),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Popular UPI Apps:',
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _upiChip('Google Pay', '@okhdfcbank'),
                _upiChip('PhonePe', '@ybl'),
                _upiChip('Paytm', '@paytm'),
                _upiChip('BHIM UPI', '@upi'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _upiChip(String label, String handle) {
    return ActionChip(
      avatar: const Icon(Icons.bolt_rounded, size: 16, color: AppColors.primary),
      label: Text(label),
      onPressed: () {
        final current = _upiController.text.trim();
        final username =
            current.contains('@') ? current.split('@').first : 'user';
        setState(() {
          _upiController.text = '$username$handle';
        });
      },
    );
  }

  // --- 2. CARD FORM ---
  Widget _buildCardForm(ThemeData theme, ColorScheme colorScheme) {
    return Form(
      key: _cardFormKey,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Credit / Debit Card',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Row(
                  children: [
                    _cardIcon('VISA'),
                    const SizedBox(width: 4),
                    _cardIcon('MC'),
                    const SizedBox(width: 4),
                    _cardIcon('RUPAY'),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              key: const Key('card_number_input_field'),
              controller: _cardNumberController,
              validator: AppValidators.validateCardNumber,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.digitsOnly,
                LengthLimitingTextInputFormatter(16),
              ],
              decoration: const InputDecoration(
                labelText: 'Card Number',
                hintText: '16 digit card number',
                prefixIcon: Icon(Icons.credit_card_rounded),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              key: const Key('card_holder_input_field'),
              controller: _cardHolderController,
              validator: AppValidators.validateName,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              decoration: const InputDecoration(
                labelText: 'Cardholder Name',
                hintText: 'Name as on card',
                prefixIcon: Icon(Icons.person_outline_rounded),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    key: const Key('card_expiry_input_field'),
                    controller: _cardExpiryController,
                    validator: AppValidators.validateCardExpiry,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    inputFormatters: [
                      LengthLimitingTextInputFormatter(5),
                    ],
                    decoration: const InputDecoration(
                      labelText: 'Expiry (MM/YY)',
                      hintText: '08/28',
                      prefixIcon: Icon(Icons.calendar_month_rounded),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    key: const Key('card_cvv_input_field'),
                    controller: _cardCvvController,
                    validator: AppValidators.validateCvv,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    keyboardType: TextInputType.number,
                    obscureText: _obscureCvv,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(3),
                    ],
                    decoration: InputDecoration(
                      labelText: 'CVV',
                      hintText: '123',
                      prefixIcon: const Icon(Icons.lock_outline_rounded),
                      suffixIcon: IconButton(
                        icon: Icon(
                          _obscureCvv
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: () {
                          setState(() {
                            _obscureCvv = !_obscureCvv;
                          });
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _cardIcon(String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryContainer,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: AppColors.primary,
        ),
      ),
    );
  }

  // --- 3. NET BANKING FORM ---
  Widget _buildNetBankingForm(ThemeData theme, ColorScheme colorScheme) {
    return Form(
      key: _netBankingFormKey,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: colorScheme.outlineVariant),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Your Bank',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            // Popular banks chips
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _popularBanks.map((bank) {
                final isSelected = _selectedBank == bank;
                return ChoiceChip(
                  key: Key('bank_chip_$bank'),
                  label: Text(
                    bank.split('(').first.trim(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected
                          ? AppColors.primary
                          : colorScheme.onSurface,
                    ),
                  ),
                  selected: isSelected,
                  selectedColor: AppColors.primaryContainer,
                  onSelected: (selected) {
                    if (selected) {
                      setState(() {
                        _selectedBank = bank;
                      });
                    }
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              key: const Key('all_banks_dropdown'),
              initialValue: _selectedBank,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'All Supported Indian Banks',
                prefixIcon: Icon(Icons.account_balance_rounded),
              ),
              items: _allBanks.map((bank) {
                return DropdownMenuItem<String>(
                  value: bank,
                  child: Text(bank, overflow: TextOverflow.ellipsis),
                );
              }).toList(),
              onChanged: (newBank) {
                if (newBank != null) {
                  setState(() {
                    _selectedBank = newBank;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecurityBadges(ThemeData theme, ColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.verified_user_rounded,
            size: 16,
            color: AppColors.secondary,
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              '256-bit SSL Encrypted • RBI Compliant • PCI-DSS Certified',
              style: theme.textTheme.labelSmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
