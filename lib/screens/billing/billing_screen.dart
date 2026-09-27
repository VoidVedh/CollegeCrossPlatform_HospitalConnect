import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/bill_provider.dart';
import 'package:hospital_connect/widgets/bill_card.dart';
import 'package:provider/provider.dart';

/// Comprehensive Billing and Payments screen with itemized breakdown and dues metrics.
class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});

  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  int _selectedFilterIndex = 0; // 0: All, 1: Pending / Unpaid, 2: Paid

  void _handlePayBill(BuildContext context, BillModel bill) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) => _BillPaymentSummarySheet(bill: bill),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final billProvider = context.watch<BillProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bills & Payments'),
        actions: [
          IconButton(
            tooltip: 'Refresh Bills',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<BillProvider>().loadBills(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _buildBody(context, billProvider, theme, colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    BillProvider provider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (provider.isLoading && provider.bills.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.bills.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: AppColors.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Unable to load bills',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                provider.error!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => provider.loadBills(),
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final allBills = provider.bills;
    final unpaidBills = provider.unpaidBills;
    final paidBills = provider.paidBills;

    // Filtered list based on selected segment
    List<BillModel> displayBills;
    switch (_selectedFilterIndex) {
      case 1:
        displayBills = unpaidBills;
        break;
      case 2:
        displayBills = paidBills;
        break;
      default:
        displayBills = allBills;
        break;
    }

    // Dynamic sum of unpaid dues computed on the fly
    final totalOutstanding = unpaidBills.fold<double>(
      0.0,
      (sum, bill) => sum + bill.totalAmount,
    );

    return RefreshIndicator(
      onRefresh: () => provider.loadBills(),
      child: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        children: [
          // 1. Outstanding Dues Metric Banner
          _buildDuesBanner(
            context,
            totalOutstanding,
            unpaidBills.length,
            theme,
            colorScheme,
          ),
          const SizedBox(height: 18),

          // 2. Filter Segment Chips
          _buildFilterSegments(
            allBills.length,
            unpaidBills.length,
            paidBills.length,
            theme,
            colorScheme,
          ),
          const SizedBox(height: 16),

          // 3. Bills List or Empty State
          if (displayBills.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 40),
              child: Center(
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.receipt_rounded,
                        size: 32,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      _selectedFilterIndex == 1
                          ? 'No Pending Dues!'
                          : 'No Invoices Found',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _selectedFilterIndex == 1
                          ? 'All your healthcare bills are settled in full.'
                          : 'Invoices for appointments and lab tests will appear here.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ...displayBills.map((bill) {
              return Padding(
                padding: const EdgeInsets.only(bottom: 14),
                child: BillCard(
                  bill: bill,
                  onPayPressed: () => _handlePayBill(context, bill),
                ),
              );
            }),
        ],
      ),
    );
  }

  Widget _buildDuesBanner(
    BuildContext context,
    double totalDues,
    int pendingCount,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final hasDues = totalDues > 0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: hasDues
            ? AppColors.primaryContainer.withValues(alpha: 0.6)
            : AppColors.statusCompleted.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: hasDues
              ? AppColors.primary.withValues(alpha: 0.3)
              : AppColors.statusCompleted.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      hasDues
                          ? Icons.pending_actions_rounded
                          : Icons.check_circle_rounded,
                      size: 18,
                      color: hasDues
                          ? AppColors.primary
                          : AppColors.statusCompleted,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      hasDues ? 'OUTSTANDING DUES' : 'ALL DUES CLEARED',
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: hasDues
                            ? AppColors.primary
                            : AppColors.statusCompleted,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  AppFormatters.formatCurrency(totalDues),
                  key: const Key('total_outstanding_dues_text'),
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: hasDues
                        ? AppColors.primary
                        : AppColors.statusCompleted,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  hasDues
                      ? '$pendingCount pending invoice${pendingCount > 1 ? 's' : ''} awaiting payment'
                      : 'Zero pending payments across all hospital visits',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: hasDues ? AppColors.primary : AppColors.statusCompleted,
              shape: BoxShape.circle,
            ),
            child: Icon(
              hasDues ? Icons.account_balance_wallet_rounded : Icons.thumb_up_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSegments(
    int allCount,
    int pendingCount,
    int paidCount,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildChip(0, 'All Bills ($allCount)', theme, colorScheme),
          const SizedBox(width: 8),
          _buildChip(1, 'Pending / Due ($pendingCount)', theme, colorScheme),
          const SizedBox(width: 8),
          _buildChip(2, 'Paid History ($paidCount)', theme, colorScheme),
        ],
      ),
    );
  }

  Widget _buildChip(
    int index,
    String label,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    final isSelected = _selectedFilterIndex == index;

    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (_) {
        setState(() {
          _selectedFilterIndex = index;
        });
      },
      showCheckmark: false,
      backgroundColor: colorScheme.surface,
      selectedColor: AppColors.primaryContainer,
      labelStyle: TextStyle(
        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        color: isSelected ? AppColors.primary : colorScheme.onSurface,
        fontSize: 13,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? AppColors.primary : colorScheme.outlineVariant,
        ),
      ),
    );
  }
}

/// Bottom sheet displaying the itemized charges breakdown and payment gateway CTA.
class _BillPaymentSummarySheet extends StatelessWidget {
  const _BillPaymentSummarySheet({required this.bill});

  final BillModel bill;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
        maxWidth: 640,
      ),
      margin: const EdgeInsets.only(top: 32),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 38,
              height: 4,
              margin: const EdgeInsets.only(bottom: 16),
              decoration: BoxDecoration(
                color: colorScheme.outlineVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Itemized Bill Summary',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    'Invoice Ref: ${bill.id}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Service info
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              bill.serviceName,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Breakdown
          _buildItemRow('Consultation Fee', bill.consultationFee, theme),
          const SizedBox(height: 8),
          _buildItemRow('Laboratory & Diagnostics', bill.labCharges, theme),
          const SizedBox(height: 8),
          _buildItemRow('Tax / GST (18%)', bill.tax, theme),
          const Divider(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Payable Amount',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              Text(
                AppFormatters.formatCurrency(bill.totalAmount),
                style: theme.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Proceed Button
          SizedBox(
            width: double.infinity,
            height: 50,
            child: FilledButton.icon(
              key: const Key('proceed_payment_gateway_button'),
              onPressed: () {
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Ready to pay ${AppFormatters.formatCurrency(bill.totalAmount)}. Payment Gateway opens in Step 17.',
                    ),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              icon: const Icon(Icons.lock_rounded, size: 18),
              label: Text(
                'Proceed to Pay ${AppFormatters.formatCurrency(bill.totalAmount)}',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(String label, double amount, ThemeData theme) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(
          AppFormatters.formatCurrency(amount),
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
