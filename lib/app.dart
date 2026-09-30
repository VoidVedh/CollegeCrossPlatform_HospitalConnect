import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_theme.dart';
import 'package:hospital_connect/routes/app_routes.dart';

/// Root application widget for HospitalConnect.
class HospitalConnectApp extends StatelessWidget {
  const HospitalConnectApp({
    super.key,
    this.useGoogleFonts = true,
  });

  /// Set to false in widget tests to avoid runtime font fetching.
  final bool useGoogleFonts;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HospitalConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(useGoogleFonts: useGoogleFonts),
      initialRoute: AppRoutes.shell,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
