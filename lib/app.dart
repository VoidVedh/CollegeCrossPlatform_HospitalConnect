import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_theme.dart';

/// Root application widget for HospitalConnect.
class HospitalConnectApp extends StatelessWidget {
  const HospitalConnectApp({super.key, this.useGoogleFonts = true});

  /// Set to false in widget tests to avoid runtime font fetching.
  final bool useGoogleFonts;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'HospitalConnect',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(useGoogleFonts: useGoogleFonts),
      home: const _ThemePreviewScreen(),
    );
  }
}

/// Temporary screen (Step 02 only) that previews the theme.
/// It is replaced by the real app shell in Step 05.
class _ThemePreviewScreen extends StatelessWidget {
  const _ThemePreviewScreen();

  @override
  Widget build(BuildContext context) {
    final ThemeData theme = Theme.of(context);
    final TextTheme text = theme.textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('HospitalConnect')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: <Widget>[
            Text('Healthcare Theme Preview', style: text.headlineSmall),
            const SizedBox(height: 4),
            Text(
              'Material 3 palette, typography and components',
              style: text.bodyMedium,
            ),
            const SizedBox(height: 16),
            const SearchBar(
              hintText: 'Search doctors, specialties',
              leading: Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.search),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text('Appointment status', style: text.titleMedium),
                    const SizedBox(height: 12),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _PreviewStatus(
                          label: 'Upcoming',
                          icon: Icons.schedule,
                          color: AppColors.statusUpcoming,
                        ),
                        _PreviewStatus(
                          label: 'Completed',
                          icon: Icons.check_circle,
                          color: AppColors.statusCompleted,
                        ),
                        _PreviewStatus(
                          label: 'Cancelled',
                          icon: Icons.cancel,
                          color: AppColors.statusCancelled,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text('Bill status', style: text.titleMedium),
                    const SizedBox(height: 12),
                    const Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: <Widget>[
                        _PreviewStatus(
                          label: 'Paid',
                          icon: Icons.verified,
                          color: AppColors.statusPaid,
                        ),
                        _PreviewStatus(
                          label: 'Unpaid',
                          icon: Icons.error,
                          color: AppColors.statusUnpaid,
                        ),
                        _PreviewStatus(
                          label: 'Pending',
                          icon: Icons.hourglass_bottom,
                          color: AppColors.statusPending,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const TextField(
              decoration: InputDecoration(
                labelText: 'Patient name',
                prefixIcon: Icon(Icons.person_outline),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () {},
              icon: const Icon(Icons.calendar_month),
              label: const Text('Book Appointment'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () {},
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Icon + text + colour badge, so status never relies on colour alone.
class _PreviewStatus extends StatelessWidget {
  const _PreviewStatus({
    required this.label,
    required this.icon,
    required this.color,
  });

  final String label;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context)
                .textTheme
                .labelMedium
                ?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}
