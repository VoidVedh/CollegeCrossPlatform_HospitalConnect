import 'package:flutter/material.dart';
import 'package:hospital_connect/models/models.dart';

/// Doctor Detail view presenting bio, reviews, and booking entrance.
/// Fully elaborated in Step 10.
class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({super.key, required this.doctor});

  final DoctorModel doctor;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(doctor.name),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                doctor.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(doctor.specialty),
              const SizedBox(height: 16),
              const Text(
                'Doctor detail view with bio and reviews arriving in Step 10.',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
