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

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      authorName: json['authorName'] as String,
      rating: (json['rating'] as num).toDouble(),
      comment: json['comment'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }

  final String id;
  final String authorName;
  final double rating;
  final String comment;
  final DateTime date;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'authorName': authorName,
      'rating': rating,
      'comment': comment,
      'date': date.toIso8601String(),
    };
  }

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
          id == other.id &&
          authorName == other.authorName &&
          rating == other.rating &&
          comment == other.comment &&
          date == other.date;

  @override
  int get hashCode => Object.hash(id, authorName, rating, comment, date);
}
