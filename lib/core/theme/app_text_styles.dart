import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Builds the accessible healthcare typography scale.
///
/// Uses Inter for readability. Set [useGoogleFonts] to false in tests
/// so no network font fetching is attempted.
class AppTextStyles {
  const AppTextStyles._();

  static TextTheme textTheme({bool useGoogleFonts = true}) {
    const TextTheme base = TextTheme(
      displaySmall: TextStyle(fontSize: 34, fontWeight: FontWeight.w700, height: 1.2),
      headlineMedium: TextStyle(fontSize: 26, fontWeight: FontWeight.w700, height: 1.25),
      headlineSmall: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, height: 1.25),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, height: 1.3),
      titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, height: 1.4),
      titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
      bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, height: 1.5),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
      bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, height: 1.4),
      labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, height: 1.4),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, height: 1.3),
      labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, height: 1.3),
    );
    return useGoogleFonts ? GoogleFonts.interTextTheme(base) : base;
  }
}
