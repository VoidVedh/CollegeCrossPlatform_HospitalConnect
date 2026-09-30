import 'package:hospital_connect/models/prescription_model.dart';
import 'package:hospital_connect/services/mock/mock_data_service.dart';
import 'package:hospital_connect/services/repositories/prescription_repository.dart';

/// Mock implementation of PrescriptionRepository with simulated latency.
class MockPrescriptionRepository implements PrescriptionRepository {
  MockPrescriptionRepository(this._dataSource);

  final MockDataService _dataSource;
  static const Duration _delay = Duration(milliseconds: 150);

  @override
  Future<List<PrescriptionModel>> getPrescriptions() async {
    await Future.delayed(_delay);
    return _dataSource.prescriptions;
  }

  @override
  Future<PrescriptionModel?> getPrescriptionById(String id) async {
    await Future.delayed(_delay);
    try {
      return _dataSource.prescriptions.firstWhere((p) => p.id == id);
    } on StateError {
      return null;
    }
  }
}
