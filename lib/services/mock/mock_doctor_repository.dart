import 'package:hospital_connect/core/errors/app_exceptions.dart';
import 'package:hospital_connect/models/doctor_model.dart';
import 'package:hospital_connect/services/mock/mock_data_service.dart';
import 'package:hospital_connect/services/repositories/doctor_repository.dart';

/// Mock implementation of DoctorRepository with simulated latency.
class MockDoctorRepository implements DoctorRepository {
  MockDoctorRepository(this._dataSource);

  final MockDataService _dataSource;
  static const Duration _delay = Duration(milliseconds: 150);

  @override
  Future<List<DoctorModel>> getDoctors() async {
    await Future.delayed(_delay);
    return _dataSource.doctors;
  }

  @override
  Future<DoctorModel?> getDoctorById(String id) async {
    await Future.delayed(_delay);
    try {
      return _dataSource.doctors.firstWhere((d) => d.id == id);
    } on StateError {
      return null;
    }
  }

  @override
  Future<List<DoctorModel>> searchDoctors(String query,
      {String? specialty}) async {
    await Future.delayed(_delay);
    final cleanQuery = query.trim().toLowerCase();
    return _dataSource.doctors.where((d) {
      final matchesQuery = cleanQuery.isEmpty ||
          d.name.toLowerCase().contains(cleanQuery) ||
          d.specialty.toLowerCase().contains(cleanQuery) ||
          d.hospitalName.toLowerCase().contains(cleanQuery);
      final matchesSpecialty = specialty == null ||
          specialty.isEmpty ||
          specialty.toLowerCase() == 'all' ||
          d.specialty.toLowerCase() == specialty.toLowerCase();
      return matchesQuery && matchesSpecialty;
    }).toList();
  }

  @override
  Future<bool> markSlotAvailability({
    required String doctorId,
    required DateTime slot,
    required bool isAvailable,
  }) async {
    await Future.delayed(_delay);
    final exists = _dataSource.doctors.any((d) => d.id == doctorId);
    if (!exists) {
      throw NotFoundException('Doctor with ID $doctorId was not found.');
    }
    _dataSource.updateDoctorSlotAvailability(doctorId, slot, isAvailable);
    return true;
  }
}
