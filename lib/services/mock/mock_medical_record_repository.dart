import 'package:hospital_connect/models/medical_record_model.dart';
import 'package:hospital_connect/services/mock/mock_data_service.dart';
import 'package:hospital_connect/services/repositories/medical_record_repository.dart';

/// Mock implementation of MedicalRecordRepository with simulated latency.
class MockMedicalRecordRepository implements MedicalRecordRepository {
  MockMedicalRecordRepository(this._dataSource);

  final MockDataService _dataSource;
  static const Duration _delay = Duration(milliseconds: 150);

  @override
  Future<List<MedicalRecordModel>> getMedicalRecords() async {
    await Future.delayed(_delay);
    return _dataSource.medicalRecords;
  }

  @override
  Future<MedicalRecordModel?> getRecordById(String id) async {
    await Future.delayed(_delay);
    try {
      return _dataSource.medicalRecords.firstWhere((r) => r.id == id);
    } on StateError {
      return null;
    }
  }
}
