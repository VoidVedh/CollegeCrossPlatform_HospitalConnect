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
}
