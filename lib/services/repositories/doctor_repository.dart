import 'package:hospital_connect/models/doctor_model.dart';

/// Abstract repository interface for Doctor data management.
abstract class DoctorRepository {
  /// Fetches the complete list of available doctors.
  Future<List<DoctorModel>> getDoctors();

  /// Fetches a single doctor by unique identifier.
  Future<DoctorModel?> getDoctorById(String id);

  /// Searches doctors by name or hospital, optionally filtering by specialty.
  Future<List<DoctorModel>> searchDoctors(String query, {String? specialty});

  /// Marks a specific slot as booked or available.
  Future<bool> markSlotAvailability({
    required String doctorId,
    required DateTime slot,
    required bool isAvailable,
  });
}
