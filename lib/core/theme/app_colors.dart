import 'package:flutter/material.dart';

/// Healthcare colour palette and app-wide status colours.
class AppColors {
  const AppColors._();

  // Brand colours
  static const Color primary = Color(0xFF006A6A); // Teal / Medical Blue
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF9CF1F0);
  static const Color onPrimaryContainer = Color(0xFF002020);

  static const Color secondary = Color(0xFF006B5D); // Emerald Green
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFF9EF2DF);
  static const Color onSecondaryContainer = Color(0xFF00201B);

  static const Color error = Color(0xFFBA1A1A); // Crimson
  static const Color onError = Color(0xFFFFFFFF);

  // Surfaces
  static const Color surface = Color(0xFFF5FAFB); // Soft ice blue
  static const Color onSurface = Color(0xFF171D1D);
  static const Color surfaceVariant = Color(0xFFDAE4E4);
  static const Color onSurfaceVariant = Color(0xFF3F4948);
  static const Color outline = Color(0xFF6F7979);
  static const Color outlineVariant = Color(0xFFBEC8C8);
  static const Color cardSurface = Color(0xFFFFFFFF);

  // Appointment status colours
  static const Color statusUpcoming = Color(0xFF006A6A);
  static const Color statusCompleted = Color(0xFF2E7D32);
  static const Color statusCancelled = Color(0xFFBA1A1A);

  // Bill status colours
  static const Color statusPaid = Color(0xFF2E7D32);
  static const Color statusUnpaid = Color(0xFFBA1A1A);
  static const Color statusPending = Color(0xFF9A5B00); // amber, contrast-safe on white

  // Utility & Accent colours
  static const Color white = Color(0xFFFFFFFF);
  static const Color transparent = Color(0x00000000);
  static const Color info = Color(0xFF0288D1);
  static const Color starRating = Color(0xFFF59E0B);
  static const Color ratingStar = Color(0xFFD97706);
  static const Color ratingStarContainer = Color(0xFFFEF3C7);
  static const Color ratingStarText = Color(0xFF92400E);
  static const Color onPrimary70 = Color(0xB3FFFFFF);
  static const Color specialtyCardiology = Color(0xFFC62828);
  static const Color specialtyNeurology = Color(0xFF6A1B9A);
  static const Color specialtyPediatrics = Color(0xFFE65100);
  static const Color specialtyOrthopedics = Color(0xFF00695C);
  static const Color specialtyDermatology = Color(0xFFAD1457);
}
