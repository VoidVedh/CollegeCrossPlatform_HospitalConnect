import 'package:flutter/material.dart';

/// Root application widget for HospitalConnect.
class HospitalConnectApp extends StatelessWidget {
  const HospitalConnectApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HospitalConnect',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006A6A),
        ),
      ),
      home: const Scaffold(
        body: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.local_hospital_rounded,
                  size: 64,
                  color: Color(0xFF006A6A),
                ),
                SizedBox(height: 16),
                Text(
                  'HospitalConnect',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF006A6A),
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Cross-Platform Healthcare Management System',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 24),
                Chip(
                  avatar: Icon(Icons.check_circle_outline_rounded, size: 18),
                  label: Text('Step 01: Setup Complete'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
