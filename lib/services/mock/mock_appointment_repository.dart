import 'package:hospital_connect/models/appointment_model.dart';
import 'package:hospital_connect/models/enums.dart';
import 'package:hospital_connect/services/mock/mock_data_service.dart';
import 'package:hospital_connect/services/repositories/appointment_repository.dart';

/// Mock implementation of AppointmentRepository with simulated async latency.
class MockAppointmentRepository implements AppointmentRepository {
  MockAppointmentRepository(this._dataSource);

  final MockDataService _dataSource;
  static const Duration _delay = Duration(milliseconds: 150);

  @override
  Future<List<AppointmentModel>> getAppointments() async {
    await Future.delayed(_delay);
    return _dataSource.appointments;
  }

  @override
  Future<AppointmentModel?> getAppointmentById(String id) async {
    await Future.delayed(_delay);
    try {
      return _dataSource.appointments.firstWhere((a) => a.id == id);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<AppointmentModel> bookAppointment(AppointmentModel appointment) async {
    await Future.delayed(_delay);
    _dataSource.addAppointment(appointment);
    return appointment;
  }

  @override
  Future<AppointmentModel> cancelAppointment(String id) async {
    await Future.delayed(_delay);
    _dataSource.updateAppointmentStatus(id, AppointmentStatus.cancelled);
    final updated = _dataSource.appointments.firstWhere((a) => a.id == id);
    return updated;
  }

  @override
  Future<bool> deleteAppointment(String id) async {
    await Future.delayed(_delay);
    _dataSource.deleteAppointment(id);
    return true;
  }
}
