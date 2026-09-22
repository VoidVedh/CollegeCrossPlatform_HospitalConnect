import 'package:flutter/foundation.dart';
import 'package:hospital_connect/models/enums.dart';

/// Immutable model representing a patient's booked appointment.
@immutable
class AppointmentModel {
  const AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.doctorSpecialty,
    required this.patientName,
    required this.patientAge,
    required this.patientPhone,
    required this.appointmentDate,
    required this.timeSlot,
    required this.status,
    required this.symptomsNote,
  });

  /// Unique appointment identifier formatted as "APT-XXXXXX".
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialty;
  final String patientName;
  final int patientAge;
  final String patientPhone;
  final DateTime appointmentDate;
  final String timeSlot;
  final AppointmentStatus status;
  final String symptomsNote;

  AppointmentModel copyWith({
    String? id,
    String? doctorId,
    String? doctorName,
    String? doctorSpecialty,
    String? patientName,
    int? patientAge,
    String? patientPhone,
    DateTime? appointmentDate,
    String? timeSlot,
    AppointmentStatus? status,
    String? symptomsNote,
  }) {
    return AppointmentModel(
      id: id ?? this.id,
      doctorId: doctorId ?? this.doctorId,
      doctorName: doctorName ?? this.doctorName,
      doctorSpecialty: doctorSpecialty ?? this.doctorSpecialty,
      patientName: patientName ?? this.patientName,
      patientAge: patientAge ?? this.patientAge,
      patientPhone: patientPhone ?? this.patientPhone,
      appointmentDate: appointmentDate ?? this.appointmentDate,
      timeSlot: timeSlot ?? this.timeSlot,
      status: status ?? this.status,
      symptomsNote: symptomsNote ?? this.symptomsNote,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppointmentModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
