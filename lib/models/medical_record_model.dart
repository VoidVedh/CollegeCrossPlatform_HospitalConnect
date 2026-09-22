import 'package:flutter/foundation.dart';

/// Immutable model representing an attachment (report/scan) on a medical record.
@immutable
class RecordAttachmentModel {
  const RecordAttachmentModel({
    required this.fileName,
    required this.fileType,
  });

  final String fileName;
  final String fileType;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RecordAttachmentModel &&
          runtimeType == other.runtimeType &&
          fileName == other.fileName &&
          fileType == other.fileType;

  @override
  int get hashCode => Object.hash(fileName, fileType);
}

/// Immutable model representing a patient medical visit history record.
@immutable
class MedicalRecordModel {
  const MedicalRecordModel({
    required this.id,
    required this.diagnosis,
    required this.doctorName,
    required this.visitDate,
    required this.hospitalName,
    required this.summary,
    required this.attachments,
  });

  final String id;
  final String diagnosis;
  final String doctorName;
  final DateTime visitDate;
  final String hospitalName;
  final String summary;
  final List<RecordAttachmentModel> attachments;

  MedicalRecordModel copyWith({
    String? id,
    String? diagnosis,
    String? doctorName,
    DateTime? visitDate,
    String? hospitalName,
    String? summary,
    List<RecordAttachmentModel>? attachments,
  }) {
    return MedicalRecordModel(
      id: id ?? this.id,
      diagnosis: diagnosis ?? this.diagnosis,
      doctorName: doctorName ?? this.doctorName,
      visitDate: visitDate ?? this.visitDate,
      hospitalName: hospitalName ?? this.hospitalName,
      summary: summary ?? this.summary,
      attachments: attachments ?? this.attachments,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MedicalRecordModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
