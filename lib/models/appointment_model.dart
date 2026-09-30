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

  factory AppointmentModel.fromJson(Map<String, dynamic> json) {
    return AppointmentModel(
      id: json['id'] as String,
      doctorId: json['doctorId'] as String,
      doctorName: json['doctorName'] as String,
      doctorSpecialty: json['doctorSpecialty'] as String,
      patientName: json['patientName'] as String,
      patientAge: (json['patientAge'] as num).toInt(),
      patientPhone: json['patientPhone'] as String,
      appointmentDate: DateTime.parse(json['appointmentDate'] as String),
      timeSlot: json['timeSlot'] as String,
      status: AppointmentStatus.values.firstWhere(
        (s) => s.name == json['status'],
        orElse: () => AppointmentStatus.upcoming,
      ),
      symptomsNote: json['symptomsNote'] as String,
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialty': doctorSpecialty,
      'patientName': patientName,
      'patientAge': patientAge,
      'patientPhone': patientPhone,
      'appointmentDate': appointmentDate.toIso8601String(),
      'timeSlot': timeSlot,
      'status': status.name,
      'symptomsNote': symptomsNote,
    };
  }

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
          id == other.id &&
          doctorId == other.doctorId &&
          doctorName == other.doctorName &&
          doctorSpecialty == other.doctorSpecialty &&
          patientName == other.patientName &&
          patientAge == other.patientAge &&
          patientPhone == other.patientPhone &&
          appointmentDate == other.appointmentDate &&
          timeSlot == other.timeSlot &&
          status == other.status &&
          symptomsNote == other.symptomsNote;

  @override
  int get hashCode => Object.hash(
        id,
        doctorId,
        doctorName,
        doctorSpecialty,
        patientName,
        patientAge,
        patientPhone,
        appointmentDate,
        timeSlot,
        status,
        symptomsNote,
      );
}
