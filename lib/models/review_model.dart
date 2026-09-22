import 'package:flutter/foundation.dart';

/// Immutable model representing a patient review for a doctor.
@immutable
class ReviewModel {
  const ReviewModel({
    required this.id,
    required this.authorName,
    required this.rating,
    required this.comment,
    required this.date,
  });

  final String id;
  final String authorName;
  final double rating;
  final String comment;
  final DateTime date;

  ReviewModel copyWith({
    String? id,
    String? authorName,
    double? rating,
    String? comment,
    DateTime? date,
  }) {
    return ReviewModel(
      id: id ?? this.id,
      authorName: authorName ?? this.authorName,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      date: date ?? this.date,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ReviewModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
