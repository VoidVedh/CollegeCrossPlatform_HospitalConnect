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

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
      id: json['id'] as String,
      name: json['name'] as String,
      specialty: json['specialty'] as String,
      rating: (json['rating'] as num).toDouble(),
      experienceYears: (json['experienceYears'] as num).toInt(),
      hospitalName: json['hospitalName'] as String,
      clinicAddress: json['clinicAddress'] as String,
      consultationFee: (json['consultationFee'] as num).toDouble(),
      availableSlots: (json['availableSlots'] as List<dynamic>?)
              ?.map((slot) => DateTime.parse(slot as String))
              .toList() ??
          <DateTime>[],
      imageUrl: (json['imageUrl'] as String?) ?? '',
      about: json['about'] as String,
      reviews: (json['reviews'] as List<dynamic>?)
              ?.map((r) => ReviewModel.fromJson(r as Map<String, dynamic>))
              .toList() ??
          <ReviewModel>[],
    );
  }

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

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'specialty': specialty,
      'rating': rating,
      'experienceYears': experienceYears,
      'hospitalName': hospitalName,
      'clinicAddress': clinicAddress,
      'consultationFee': consultationFee,
      'availableSlots':
          availableSlots.map((s) => s.toIso8601String()).toList(),
      'imageUrl': imageUrl,
      'about': about,
      'reviews': reviews.map((r) => r.toJson()).toList(),
    };
  }

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
          id == other.id &&
          name == other.name &&
          specialty == other.specialty &&
          rating == other.rating &&
          experienceYears == other.experienceYears &&
          hospitalName == other.hospitalName &&
          clinicAddress == other.clinicAddress &&
          consultationFee == other.consultationFee &&
          listEquals(availableSlots, other.availableSlots) &&
          imageUrl == other.imageUrl &&
          about == other.about &&
          listEquals(reviews, other.reviews);

  @override
  int get hashCode => Object.hash(
        id,
        name,
        specialty,
        rating,
        experienceYears,
        hospitalName,
        clinicAddress,
        consultationFee,
        Object.hashAll(availableSlots),
        imageUrl,
        about,
        Object.hashAll(reviews),
      );
}
