import 'package:hospital_connect/models/medical_record_model.dart';

/// Abstract repository interface for Medical History records.
abstract class MedicalRecordRepository {
  /// Fetches all patient medical records chronologically.
  Future<List<MedicalRecordModel>> getMedicalRecords();

  /// Fetches a specific medical record by ID.
  Future<MedicalRecordModel?> getRecordById(String id);
}
