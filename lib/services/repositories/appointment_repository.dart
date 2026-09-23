import 'package:hospital_connect/models/appointment_model.dart';

/// Abstract repository interface for Appointment operations.
abstract class AppointmentRepository {
  /// Fetches all booked appointments.
  Future<List<AppointmentModel>> getAppointments();

  /// Fetches an appointment by unique identifier.
  Future<AppointmentModel?> getAppointmentById(String id);

  /// Books a new appointment and persists it.
  Future<AppointmentModel> bookAppointment(AppointmentModel appointment);

  /// Cancels an upcoming appointment.
  Future<AppointmentModel> cancelAppointment(String id);
}
