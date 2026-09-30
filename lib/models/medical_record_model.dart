import 'package:flutter/foundation.dart';

/// Immutable model representing an attachment (report/scan) on a medical record.
@immutable
class RecordAttachmentModel {
  const RecordAttachmentModel({
    required this.fileName,
    required this.fileType,
  });

  factory RecordAttachmentModel.fromJson(Map<String, dynamic> json) {
    return RecordAttachmentModel(
      fileName: json['fileName'] as String,
      fileType: json['fileType'] as String,
    );
  }

  final String fileName;
  final String fileType;

  Map<String, dynamic> toJson() {
    return {
      'fileName': fileName,
      'fileType': fileType,
    };
  }

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

  factory MedicalRecordModel.fromJson(Map<String, dynamic> json) {
    return MedicalRecordModel(
      id: json['id'] as String,
      diagnosis: json['diagnosis'] as String,
      doctorName: json['doctorName'] as String,
      visitDate: DateTime.parse(json['visitDate'] as String),
      hospitalName: json['hospitalName'] as String,
      summary: json['summary'] as String,
      attachments: (json['attachments'] as List<dynamic>?)
              ?.map(
                  (a) => RecordAttachmentModel.fromJson(a as Map<String, dynamic>))
              .toList() ??
          <RecordAttachmentModel>[],
    );
  }

  final String id;
  final String diagnosis;
  final String doctorName;
  final DateTime visitDate;
  final String hospitalName;
  final String summary;
  final List<RecordAttachmentModel> attachments;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'diagnosis': diagnosis,
      'doctorName': doctorName,
      'visitDate': visitDate.toIso8601String(),
      'hospitalName': hospitalName,
      'summary': summary,
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

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
          id == other.id &&
          diagnosis == other.diagnosis &&
          doctorName == other.doctorName &&
          visitDate == other.visitDate &&
          hospitalName == other.hospitalName &&
          summary == other.summary &&
          listEquals(attachments, other.attachments);

  @override
  int get hashCode => Object.hash(
        id,
        diagnosis,
        doctorName,
        visitDate,
        hospitalName,
        summary,
        Object.hashAll(attachments),
      );
}
