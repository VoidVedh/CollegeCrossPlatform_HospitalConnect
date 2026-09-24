import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/appointment_provider.dart';
import 'package:hospital_connect/providers/doctor_provider.dart';
import 'package:hospital_connect/widgets/widgets.dart';
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
    final colorScheme = theme.colorScheme;
    final doctorProvider = context.watch<DoctorProvider>();
    final appointmentProvider = context.watch<AppointmentProvider>();
    final nextAppointment = appointmentProvider.nextUpcomingAppointment;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // 1. Top Header: Patient Greeting & Emergency Pill
            _buildPatientHeader(context, theme, colorScheme),
            const SizedBox(height: 16),

            // 2. Search Bar
            _buildSearchBar(context, doctorProvider),
            const SizedBox(height: 20),

            // 3. Upcoming Appointment Highlight Card
            Text(
              'Upcoming Appointment',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            UpcomingAppointmentCard(
              appointment: nextAppointment,
              onTapBook: () => _navigateToTab(1, '/doctors'),
              onTapDetails: () => _navigateToTab(2, '/appointments'),
            ),
            const SizedBox(height: 24),

            // 4. Quick Action Cards (2x2 Grid)
            Text(
              'Quick Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 12),
            _buildQuickActionsGrid(context),
            const SizedBox(height: 24),

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
            const SizedBox(height: 12),
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
                    onTap: () {
                      doctorProvider.setSpecialty(label);
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 24),

            // 6. Top Rated Doctors Carousel
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Top Rated Specialists',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextButton(
                  onPressed: () => _navigateToTab(1, '/doctors'),
                  child: const Text('View All'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTopDoctorsCarousel(context, doctorProvider.topRatedDoctors),
            const SizedBox(height: 24),
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
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.error.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: AppColors.error.withValues(alpha: 0.3),
            ),
          ),
          child: const Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.emergency_rounded,
                size: 16,
                color: AppColors.error,
              ),
              SizedBox(width: 4),
              Text(
                'SOS 108',
                style: TextStyle(
                  color: AppColors.error,
                  fontSize: 12,
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

  Widget _buildQuickActionsGrid(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 600 ? 4 : 2;
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.2,
          children: [
            QuickActionCard(
              title: 'Book Visit',
              subtitle: 'Top Doctors',
              icon: Icons.calendar_today_rounded,
              accentColor: AppColors.primary,
              onTap: () => _navigateToTab(1, '/doctors'),
            ),
            QuickActionCard(
              title: 'Prescriptions',
              subtitle: 'Digital Rx',
              icon: Icons.medication_rounded,
              accentColor: AppColors.secondary,
              onTap: () {
                // Prescriptions tab or sheet
                _navigateToTab(3, '/records');
              },
            ),
            QuickActionCard(
              title: 'Records',
              subtitle: 'Lab & Scans',
              icon: Icons.folder_shared_rounded,
              accentColor: const Color(0xFF0D47A1),
              onTap: () => _navigateToTab(3, '/records'),
            ),
            QuickActionCard(
              title: 'Pay Bills',
              subtitle: 'Itemized dues',
              icon: Icons.receipt_long_rounded,
              accentColor: AppColors.statusPending,
              onTap: () => _navigateToTab(4, '/billing'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTopDoctorsCarousel(
      BuildContext context, List<DoctorModel> topDoctors) {
    if (topDoctors.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 172,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: topDoctors.length,
        separatorBuilder: (_, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final doctor = topDoctors[index];
          return _TopDoctorItemCard(
            doctor: doctor,
            onTap: () => _navigateToTab(1, '/doctors'),
          );
        },
      ),
    );
  }
}

class _TopDoctorItemCard extends StatelessWidget {
  const _TopDoctorItemCard({
    required this.doctor,
    required this.onTap,
  });

  final DoctorModel doctor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: 220,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: colorScheme.primaryContainer,
                child: Text(
                  doctor.name.split(' ').map((p) => p[0]).take(2).join(),
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: colorScheme.onPrimaryContainer,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doctor.name,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      doctor.specialty,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                        fontSize: 11,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Spacer(),
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 16, color: Color(0xFFF59E0B)),
              const SizedBox(width: 4),
              Text(
                doctor.rating.toStringAsFixed(1),
                style: theme.textTheme.labelMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                AppFormatters.formatCurrency(doctor.consultationFee),
                style: theme.textTheme.labelLarge?.copyWith(
                  color: colorScheme.primary,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            height: 36,
            child: OutlinedButton(
              onPressed: onTap,
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Consult', style: TextStyle(fontSize: 12)),
            ),
          ),
        ],
      ),
    );
  }
}
