import 'package:hospital_connect/models/bill_model.dart';
import 'package:hospital_connect/models/enums.dart';
import 'package:hospital_connect/services/mock/mock_data_service.dart';
import 'package:hospital_connect/services/repositories/bill_repository.dart';

/// Mock implementation of BillRepository with simulated latency.
class MockBillRepository implements BillRepository {
  MockBillRepository(this._dataSource);

  final MockDataService _dataSource;
  static const Duration _delay = Duration(milliseconds: 150);

  @override
  Future<List<BillModel>> getBills() async {
    await Future.delayed(_delay);
    return _dataSource.bills;
  }

  @override
  Future<BillModel?> getBillById(String id) async {
    await Future.delayed(_delay);
    try {
      return _dataSource.bills.firstWhere((b) => b.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<BillModel> addBill(BillModel bill) async {
    await Future.delayed(_delay);
    _dataSource.addBill(bill);
    return bill;
  }

  @override
  Future<BillModel> updateBillStatus({
    required String billId,
    required BillStatus status,
    PaymentMethodType? paymentMethod,
    DateTime? paidAt,
  }) async {
    await Future.delayed(_delay);
    _dataSource.updateBill(
      billId,
      status,
      paymentMethod: paymentMethod,
      paidAt: paidAt,
    );
    final updated = _dataSource.bills.firstWhere((b) => b.id == billId);
    return updated;
  }

  @override
  Future<bool> removeBill(String id) async {
    await Future.delayed(_delay);
    _dataSource.removeBill(id);
    return true;
  }
}
