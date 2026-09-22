import 'package:flutter/foundation.dart';

/// Immutable model representing an individual medication item in a prescription.
@immutable
class MedicationModel {
  const MedicationModel({
    required this.name,
    required this.dosage,
    required this.frequency,
    required this.duration,
  });

  final String name;
  final String dosage;
  final String frequency;
  final String duration;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicationModel &&
          runtimeType == other.runtimeType &&
          name == other.name &&
          dosage == other.dosage &&
          frequency == other.frequency &&
          duration == other.duration;

  @override
  int get hashCode => Object.hash(name, dosage, frequency, duration);
}

/// Immutable model representing an official doctor prescription.
@immutable
class PrescriptionModel {
  const PrescriptionModel({
    required this.id,
    required this.doctorName,
    required this.issueDate,
    required this.diagnosis,
    required this.medications,
    required this.instructions,
  });

  final String id;
  final String doctorName;
  final DateTime issueDate;
  final String diagnosis;
  final List<MedicationModel> medications;
  final String instructions;

  PrescriptionModel copyWith({
    String? id,
    String? doctorName,
    DateTime? issueDate,
    String? diagnosis,
    List<MedicationModel>? medications,
    String? instructions,
  }) {
    return PrescriptionModel(
      id: id ?? this.id,
      doctorName: doctorName ?? this.doctorName,
      issueDate: issueDate ?? this.issueDate,
      diagnosis: diagnosis ?? this.diagnosis,
      medications: medications ?? this.medications,
      instructions: instructions ?? this.instructions,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PrescriptionModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
