import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/providers/doctor_provider.dart';
import 'package:hospital_connect/widgets/widgets.dart';
import 'package:provider/provider.dart';

/// Patient Dashboard Screen featuring greeting header, search bar, and specialty chips.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  static const List<Map<String, dynamic>> _specialties = [
    {'label': 'All', 'icon': Icons.medical_services_rounded},
    {'label': 'Cardiology', 'icon': Icons.favorite_rounded},
    {'label': 'Neurology', 'icon': Icons.psychology_rounded},
    {'label': 'Pediatrics', 'icon': Icons.child_care_rounded},
    {'label': 'Orthopedics', 'icon': Icons.accessibility_new_rounded},
    {'label': 'General Medicine', 'icon': Icons.local_hospital_rounded},
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final doctorProvider = context.watch<DoctorProvider>();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Top Header: Patient Greeting & Emergency Pill
            _buildPatientHeader(context, theme, colorScheme),
            const SizedBox(height: 16),

            // Search Bar
            _buildSearchBar(context, doctorProvider),
            const SizedBox(height: 20),

            // Category Chips Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Specialties',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${doctorProvider.filteredDoctors.length} doctors found',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Horizontal Category Chips List
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _specialties.length,
                separatorBuilder: (_, _) => const SizedBox(width: 8),
                itemBuilder: (context, index) {
                  final item = _specialties[index];
                  final label = item['label'] as String;
                  final icon = item['icon'] as IconData;
                  final isSelected =
                      doctorProvider.selectedSpecialty.toLowerCase() ==
                          label.toLowerCase();

                  return SpecialtyChip(
                    label: label,
                    icon: icon,
                    isSelected: isSelected,
                    onTap: () => doctorProvider.setSpecialty(label),
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // Quick Actions & Upcoming Appointments (Placeholder for Step 07)
            Card(
              elevation: 0,
              color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: colorScheme.outlineVariant),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.widgets_outlined,
                      size: 36,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Step 06 Active: Header, Search & Categories',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quick Action cards & Upcoming Appointment card arriving in Step 07.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPatientHeader(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Patient Initials Avatar
        CircleAvatar(
          radius: 24,
          backgroundColor: colorScheme.primaryContainer,
          child: Text(
            'AS',
            style: theme.textTheme.titleMedium?.copyWith(
              color: colorScheme.onPrimaryContainer,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Greeting
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hello, Aditya 👋',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'How are you feeling today?',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),

        // Emergency SOS Hotline Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.emergency_rounded,
                size: 16,
                color: AppColors.error,
              ),
              const SizedBox(width: 4),
              Text(
                'SOS 108',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.error,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context, DoctorProvider doctorProvider) {
    return SearchBar(
      controller: _searchController,
      hintText: 'Search doctors, specialties...',
      leading: const Padding(
        padding: EdgeInsets.only(left: 12),
        child: Icon(Icons.search_rounded),
      ),
      trailing: _searchController.text.isNotEmpty
          ? [
              IconButton(
                icon: const Icon(Icons.close_rounded),
                onPressed: () {
                  _searchController.clear();
                  doctorProvider.setSearchQuery('');
                },
              ),
            ]
          : null,
      onChanged: (value) {
        setState(() {});
        doctorProvider.setSearchQuery(value);
      },
    );
  }
}
