import 'package:flutter/material.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/screens/app_shell.dart';
import 'package:hospital_connect/screens/appointments/booking_screen.dart';
import 'package:hospital_connect/screens/doctors/doctor_detail_screen.dart';
import 'package:hospital_connect/screens/payment/payment_screen.dart';

/// Centralized route definitions and generator for HospitalConnect.
class AppRoutes {
  AppRoutes._();

  static const String shell = '/';
  static const String doctorDetail = '/doctor-detail';
  static const String booking = '/booking';
  static const String payment = '/payment';

  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case shell:
        return MaterialPageRoute<void>(
          builder: (_) => const AppShell(),
          settings: settings,
        );

      case doctorDetail:
        final args = settings.arguments;
        if (args is String) {
          return MaterialPageRoute<void>(
            builder: (_) => DoctorDetailScreen(doctorId: args),
            settings: settings,
          );
        } else if (args is DoctorModel) {
          return MaterialPageRoute<void>(
            builder: (_) => DoctorDetailScreen(doctor: args),
            settings: settings,
          );
        }
        return null;

      case booking:
        final args = settings.arguments;
        if (args is String) {
          return MaterialPageRoute<void>(
            builder: (_) => BookingScreen(doctorId: args),
            settings: settings,
          );
        } else if (args is DoctorModel) {
          return MaterialPageRoute<void>(
            builder: (_) => BookingScreen(doctor: args),
            settings: settings,
          );
        }
        return null;

      case payment:
        final args = settings.arguments;
        if (args is String) {
          return MaterialPageRoute<void>(
            builder: (_) => PaymentScreen(billId: args),
            settings: settings,
          );
        } else if (args is BillModel) {
          return MaterialPageRoute<void>(
            builder: (_) => PaymentScreen(bill: args),
            settings: settings,
          );
        }
        return null;

      default:
        return null;
    }
  }
}
