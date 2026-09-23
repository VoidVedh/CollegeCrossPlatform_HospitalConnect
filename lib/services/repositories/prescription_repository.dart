import 'package:hospital_connect/models/prescription_model.dart';

/// Abstract repository interface for Doctor Prescriptions.
abstract class PrescriptionRepository {
  /// Fetches all digital prescriptions.
  Future<List<PrescriptionModel>> getPrescriptions();

  /// Fetches a single prescription by ID.
  Future<PrescriptionModel?> getPrescriptionById(String id);
}
