import 'package:flutter/foundation.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/services/repositories/repositories.dart';
import 'package:uuid/uuid.dart';

/// State management provider for patient appointments and bookings.
class AppointmentProvider extends ChangeNotifier {
  AppointmentProvider(this._repository) {
    loadAppointments();
  }

  final AppointmentRepository _repository;
  static const Uuid _uuid = Uuid();

  List<AppointmentModel> _appointments = <AppointmentModel>[];
  bool _isLoading = false;
  String? _error;

  List<AppointmentModel> get appointments => List.unmodifiable(_appointments);
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<AppointmentModel> get upcomingAppointments => _appointments
      .where((a) => a.status == AppointmentStatus.upcoming)
      .toList();

  List<AppointmentModel> get pastAppointments => _appointments
      .where((a) =>
          a.status == AppointmentStatus.completed ||
          a.status == AppointmentStatus.cancelled)
      .toList();

  /// Highlights the immediate next upcoming appointment for dashboard card.
  AppointmentModel? get nextUpcomingAppointment {
    final upcoming = upcomingAppointments;
    if (upcoming.isEmpty) return null;
    final sorted = List<AppointmentModel>.from(upcoming)
      ..sort((a, b) => a.appointmentDate.compareTo(b.appointmentDate));
    return sorted.first;
  }

  Future<void> loadAppointments() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _appointments = await _repository.getAppointments();
    } catch (e) {
      _error = 'Failed to load appointments: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Single centralized method to book an appointment with auto-generated ID (format "APT-XXXXXX").
  Future<AppointmentModel> bookAppointment({
    required String doctorId,
    required String doctorName,
    required String doctorSpecialty,
    required String patientName,
    required int patientAge,
    required String patientPhone,
    required DateTime appointmentDate,
    required String timeSlot,
    required String symptomsNote,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Auto-generate ID formatted as "APT-XXXXXX"
      final randomSuffix = _uuid.v4().substring(0, 6).toUpperCase();
      final appointmentId = 'APT-$randomSuffix';

      final newAppointment = AppointmentModel(
        id: appointmentId,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpecialty: doctorSpecialty,
        patientName: patientName,
        patientAge: patientAge,
        patientPhone: patientPhone,
        appointmentDate: appointmentDate,
        timeSlot: timeSlot,
        status: AppointmentStatus.upcoming,
        symptomsNote: symptomsNote,
      );

      final booked = await _repository.bookAppointment(newAppointment);
      _appointments.insert(0, booked);
      return booked;
    } catch (e) {
      _error = 'Booking failed: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Cancels an upcoming appointment.
  Future<AppointmentModel> cancelAppointment(String appointmentId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final cancelled = await _repository.cancelAppointment(appointmentId);
      final index = _appointments.indexWhere((a) => a.id == appointmentId);
      if (index != -1) {
        _appointments[index] = cancelled;
      }
      return cancelled;
    } catch (e) {
      _error = 'Cancellation failed: $e';
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
