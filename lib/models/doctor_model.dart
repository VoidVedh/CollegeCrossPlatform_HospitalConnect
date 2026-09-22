import 'package:flutter/foundation.dart';
import 'package:hospital_connect/models/review_model.dart';

/// Immutable domain model representing a doctor in the hospital system.
@immutable
class DoctorModel {
  const DoctorModel({
    required this.id,
    required this.name,
    required this.specialty,
    required this.rating,
    required this.experienceYears,
    required this.hospitalName,
    required this.clinicAddress,
    required this.consultationFee,
    required this.availableSlots,
    this.imageUrl = '',
    required this.about,
    required this.reviews,
  });

  final String id;
  final String name;
  final String specialty;
  final double rating;
  final int experienceYears;
  final String hospitalName;
  final String clinicAddress;
  final double consultationFee;
  final List<DateTime> availableSlots;
  final String imageUrl;
  final String about;
  final List<ReviewModel> reviews;

  DoctorModel copyWith({
    String? id,
    String? name,
    String? specialty,
    double? rating,
    int? experienceYears,
    String? hospitalName,
    String? clinicAddress,
    double? consultationFee,
    List<DateTime>? availableSlots,
    String? imageUrl,
    String? about,
    List<ReviewModel>? reviews,
  }) {
    return DoctorModel(
      id: id ?? this.id,
      name: name ?? this.name,
      specialty: specialty ?? this.specialty,
      rating: rating ?? this.rating,
      experienceYears: experienceYears ?? this.experienceYears,
      hospitalName: hospitalName ?? this.hospitalName,
      clinicAddress: clinicAddress ?? this.clinicAddress,
      consultationFee: consultationFee ?? this.consultationFee,
      availableSlots: availableSlots ?? this.availableSlots,
      imageUrl: imageUrl ?? this.imageUrl,
      about: about ?? this.about,
      reviews: reviews ?? this.reviews,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DoctorModel &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
