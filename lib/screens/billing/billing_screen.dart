import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/bill_provider.dart';
import 'package:hospital_connect/screens/billing/widgets/bill_payment_bottom_sheet.dart';
import 'package:hospital_connect/screens/billing/widgets/billing_filter_segments.dart';
import 'package:hospital_connect/screens/billing/widgets/dues_summary_banner.dart';
import 'package:hospital_connect/widgets/bill_card.dart';
import 'package:hospital_connect/widgets/common/empty_state.dart';
import 'package:hospital_connect/widgets/common/error_state.dart';
import 'package:hospital_connect/widgets/payment_receipt_dialog.dart';
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
    BillPaymentBottomSheet.show(context, bill: bill);
  }

  @override
  Widget build(BuildContext context) {
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
            child: _buildBody(context, billProvider),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(BuildContext context, BillProvider provider) {
    if (provider.isLoading && provider.bills.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.bills.isEmpty) {
      return ErrorState(
        title: 'Unable to load bills',
        message: provider.error!,
        onRetry: () => provider.loadBills(),
      );
    }

    final allBills = provider.bills;
    final unpaidBills = provider.unpaidBills;
    final paidBills = provider.paidBills;

    final List<BillModel> displayBills;
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

    final totalOutstanding = unpaidBills.fold<double>(
      0.0,
      (sum, bill) => sum + bill.totalAmount,
    );

    return RefreshIndicator(
      onRefresh: () => provider.loadBills(),
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        children: [
          // 1. Outstanding Dues Metric Banner
          DuesSummaryBanner(
            totalDues: totalOutstanding,
            pendingCount: unpaidBills.length,
          ),
          const SizedBox(height: AppSpacing.lg),

          // 2. Filter Segment Chips
          BillingFilterSegments(
            selectedIndex: _selectedFilterIndex,
            allCount: allBills.length,
            pendingCount: unpaidBills.length,
            paidCount: paidBills.length,
            onSegmentSelected: (index) {
              setState(() => _selectedFilterIndex = index);
            },
          ),
          const SizedBox(height: AppSpacing.lg),

          // 3. Bills List or Empty State
          if (displayBills.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xxl),
              child: EmptyState(
                icon: Icons.receipt_rounded,
                title: _selectedFilterIndex == 1
                    ? 'No Pending Dues!'
                    : 'No Invoices Found',
                message: _selectedFilterIndex == 1
                    ? 'All your healthcare bills are settled in full.'
                    : 'Invoices for appointments and lab tests will appear here.',
              ),
            )
          else
            ...displayBills.map((bill) {
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.md + 2),
                child: BillCard(
                  bill: bill,
                  onPayPressed: () => _handlePayBill(context, bill),
                  onViewReceipt: () =>
                      PaymentReceiptDialog.show(context, bill: bill),
                ),
              );
            }),
        ],
      ),
    );
  }
}
