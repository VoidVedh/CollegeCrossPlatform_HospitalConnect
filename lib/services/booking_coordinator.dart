import 'package:flutter/foundation.dart';
import 'package:hospital_connect/core/utils/safe_notifier.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/appointment_provider.dart';
import 'package:hospital_connect/providers/bill_provider.dart';
import 'package:hospital_connect/providers/doctor_provider.dart';

/// Coordinator service orchestrating appointments, doctor slot availability,
/// and itemized billing to keep providers synchronized without manual UI glue.
class BookingCoordinator extends ChangeNotifier with SafeNotifier {
  BookingCoordinator({
    required this.appointmentProvider,
    required this.doctorProvider,
    required this.billProvider,
  });

  AppointmentProvider appointmentProvider;
  DoctorProvider doctorProvider;
  BillProvider billProvider;

  /// Updates provider references when rebuilt by [ChangeNotifierProxyProvider3].
  void update({
    required AppointmentProvider appointmentProvider,
    required DoctorProvider doctorProvider,
    required BillProvider billProvider,
  }) {
    this.appointmentProvider = appointmentProvider;
    this.doctorProvider = doctorProvider;
    this.billProvider = billProvider;
  }

  /// Atomically books an appointment and synchronizes doctor slots and bills across providers.
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
    required double consultationFee,
    DateTime? currentTime,
  }) async {
    final booked = await appointmentProvider.bookAppointment(
      doctorId: doctorId,
      doctorName: doctorName,
      doctorSpecialty: doctorSpecialty,
      patientName: patientName,
      patientAge: patientAge,
      patientPhone: patientPhone,
      appointmentDate: appointmentDate,
      timeSlot: timeSlot,
      symptomsNote: symptomsNote,
      consultationFee: consultationFee,
      currentTime: currentTime,
    );

    // Synchronize doctor slots and bills lists across providers
    await Future.wait([
      doctorProvider.loadDoctors(),
      billProvider.loadBills(),
    ]);

    notifyListeners();
    return booked;
  }

  /// Cancels an appointment and synchronizes doctor slots and bills across providers.
  Future<AppointmentModel> cancelAppointment(String appointmentId) async {
    final cancelled = await appointmentProvider.cancelAppointment(appointmentId);

    // Synchronize doctor slots and bills lists across providers
    await Future.wait([
      doctorProvider.loadDoctors(),
      billProvider.loadBills(),
    ]);

    notifyListeners();
    return cancelled;
  }
}
