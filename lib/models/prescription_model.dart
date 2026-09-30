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

  factory MedicationModel.fromJson(Map<String, dynamic> json) {
    return MedicationModel(
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      frequency: json['frequency'] as String,
      duration: json['duration'] as String,
    );
  }

  final String name;
  final String dosage;
  final String frequency;
  final String duration;

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'dosage': dosage,
      'frequency': frequency,
      'duration': duration,
    };
  }

  MedicationModel copyWith({
    String? name,
    String? dosage,
    String? frequency,
    String? duration,
  }) {
    return MedicationModel(
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      frequency: frequency ?? this.frequency,
      duration: duration ?? this.duration,
    );
  }

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

  factory PrescriptionModel.fromJson(Map<String, dynamic> json) {
    return PrescriptionModel(
      id: json['id'] as String,
      doctorName: json['doctorName'] as String,
      issueDate: DateTime.parse(json['issueDate'] as String),
      diagnosis: json['diagnosis'] as String,
      medications: (json['medications'] as List<dynamic>?)
              ?.map((m) => MedicationModel.fromJson(m as Map<String, dynamic>))
              .toList() ??
          <MedicationModel>[],
      instructions: json['instructions'] as String,
    );
  }

  final String id;
  final String doctorName;
  final DateTime issueDate;
  final String diagnosis;
  final List<MedicationModel> medications;
  final String instructions;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'doctorName': doctorName,
      'issueDate': issueDate.toIso8601String(),
      'diagnosis': diagnosis,
      'medications': medications.map((m) => m.toJson()).toList(),
      'instructions': instructions,
    };
  }

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
          id == other.id &&
          doctorName == other.doctorName &&
          issueDate == other.issueDate &&
          diagnosis == other.diagnosis &&
          listEquals(medications, other.medications) &&
          instructions == other.instructions;

  @override
  int get hashCode => Object.hash(
        id,
        doctorName,
        issueDate,
        diagnosis,
        Object.hashAll(medications),
        instructions,
      );
}
