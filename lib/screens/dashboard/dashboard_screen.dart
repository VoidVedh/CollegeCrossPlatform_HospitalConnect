import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/providers/appointment_provider.dart';
import 'package:hospital_connect/providers/doctor_provider.dart';
import 'package:hospital_connect/screens/dashboard/widgets/dashboard_patient_header.dart';
import 'package:hospital_connect/screens/dashboard/widgets/quick_actions_grid.dart';
import 'package:hospital_connect/screens/dashboard/widgets/specialty_chips_row.dart';
import 'package:hospital_connect/screens/dashboard/widgets/top_doctors_carousel.dart';
import 'package:hospital_connect/widgets/common/section_header.dart';
import 'package:hospital_connect/widgets/upcoming_appointment_card.dart';
import 'package:provider/provider.dart';

/// Patient Dashboard Screen featuring greeting header, search bar,
/// specialty category chips, upcoming appointment card, quick actions,
/// and top-rated doctors carousel.
class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key, this.onSelectTab});

  final ValueChanged<int>? onSelectTab;

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateToTab(int tabIndex, String routeName) {
    if (widget.onSelectTab != null) {
      widget.onSelectTab!(tabIndex);
    } else {
      Navigator.of(context).pushNamed(routeName);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final doctorProvider = context.watch<DoctorProvider>();
    final appointmentProvider = context.watch<AppointmentProvider>();
    final nextAppointment = appointmentProvider.nextUpcomingAppointment;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.lg,
            vertical: AppSpacing.md,
          ),
          children: [
            // 1. Top Header: Patient Greeting & Emergency Pill
            const DashboardPatientHeader(),
            const SizedBox(height: AppSpacing.lg),

            // 2. Search Bar
            _buildSearchBar(doctorProvider),
            const SizedBox(height: AppSpacing.xl),

            // 3. Upcoming Appointment Highlight Card
            Text(
              'Upcoming Appointment',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            UpcomingAppointmentCard(
              appointment: nextAppointment,
              onTapBook: () => _navigateToTab(1, '/doctors'),
              onTapDetails: () => _navigateToTab(2, '/appointments'),
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 4. Quick Action Cards (2x2 Grid)
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            QuickActionsGrid(onNavigateToTab: _navigateToTab),
            const SizedBox(height: AppSpacing.xxl),

            // 5. Category Chips Section
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Find by Specialty',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  '${doctorProvider.filteredDoctors.length} doctors',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            SpecialtyChipsRow(
              selectedSpecialty: doctorProvider.selectedSpecialty,
              onSpecialtySelected: (specialty) {
                doctorProvider.setSpecialty(specialty);
              },
            ),
            const SizedBox(height: AppSpacing.xxl),

            // 6. Top Rated Doctors Carousel
            SectionHeader(
              title: 'Top Rated Specialists',
              actionLabel: 'View All',
              onAction: () => _navigateToTab(1, '/doctors'),
            ),
            const SizedBox(height: AppSpacing.sm),
            TopDoctorsCarousel(
              topDoctors: doctorProvider.topRatedDoctors,
              onTapDoctor: (doctor) => _navigateToTab(1, '/doctors'),
            ),
            const SizedBox(height: AppSpacing.xxl),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(DoctorProvider doctorProvider) {
    return SearchBar(
      controller: _searchController,
      hintText: 'Search doctors, specialties...',
      leading: const Padding(
        padding: EdgeInsets.only(left: AppSpacing.md),
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
