import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_theme.dart';
import 'package:hospital_connect/providers/theme_provider.dart';
import 'package:hospital_connect/routes/app_routes.dart';
import 'package:provider/provider.dart';

/// Root application widget for HospitalConnect with dynamic Light & Dark mode support.
class HospitalConnectApp extends StatelessWidget {
  const HospitalConnectApp({
    super.key,
    this.useGoogleFonts = true,
  });

  /// Set to false in widget tests to avoid runtime font fetching.
  final bool useGoogleFonts;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider?>(context);
    final themeMode = themeProvider?.themeMode ?? ThemeMode.system;

    return MaterialApp(
      title: 'HospitalConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(useGoogleFonts: useGoogleFonts),
      darkTheme: AppTheme.dark(useGoogleFonts: useGoogleFonts),
      themeMode: themeMode,
      initialRoute: AppRoutes.shell,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    );
  }
}
