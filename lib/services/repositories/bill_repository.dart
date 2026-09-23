import 'package:hospital_connect/models/bill_model.dart';
import 'package:hospital_connect/models/enums.dart';

/// Abstract repository interface for Billing records.
abstract class BillRepository {
  /// Fetches all billing invoices.
  Future<List<BillModel>> getBills();

  /// Fetches a single bill by ID.
  Future<BillModel?> getBillById(String id);

  /// Inserts a new bill (e.g. linked to a booked appointment).
  Future<BillModel> addBill(BillModel bill);

  /// Updates bill status, payment method and timestamp after settlement.
  Future<BillModel> updateBillStatus({
    required String billId,
    required BillStatus status,
    PaymentMethodType? paymentMethod,
    DateTime? paidAt,
  });
}
