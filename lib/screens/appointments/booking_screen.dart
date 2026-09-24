import 'package:flutter/material.dart';
import 'package:hospital_connect/models/models.dart';

/// Appointment booking flow screen.
/// DatePicker and time-slot selector will be implemented in Step 11.
class BookingScreen extends StatelessWidget {
  const BookingScreen({super.key, required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Appointment'),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Booking for ${doctor.name}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(doctor.specialty),
              const SizedBox(height: 16),
              const Text(
                'DatePicker and Time-Slot selector arriving in Step 11.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
