import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/doctor_provider.dart';
import 'package:hospital_connect/screens/doctors/doctor_detail_screen.dart';
import 'package:hospital_connect/widgets/widgets.dart';
import 'package:provider/provider.dart';

enum DoctorSortOption {
  rating,
  experience,
  feeAsc,
}

/// Filterable, searchable catalog of hospital doctors.
class DoctorsScreen extends StatefulWidget {
  const DoctorsScreen({super.key});

  @override
  State<DoctorsScreen> createState() => _DoctorsScreenState();
}

class _DoctorsScreenState extends State<DoctorsScreen> {
  final TextEditingController _searchController = TextEditingController();
  DoctorSortOption _currentSort = DoctorSortOption.rating;

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

  List<DoctorModel> _sortDoctors(List<DoctorModel> list) {
    final sorted = List<DoctorModel>.from(list);
    switch (_currentSort) {
      case DoctorSortOption.rating:
        sorted.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case DoctorSortOption.experience:
        sorted.sort((a, b) => b.experienceYears.compareTo(a.experienceYears));
        break;
      case DoctorSortOption.feeAsc:
        sorted.sort((a, b) => a.consultationFee.compareTo(b.consultationFee));
        break;
    }
    return sorted;
  }

  void _navigateToDetail(BuildContext context, DoctorModel doctor) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => DoctorDetailScreen(doctor: doctor),
        settings: const RouteSettings(name: '/doctor-detail'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final doctorProvider = context.watch<DoctorProvider>();

    final filtered = doctorProvider.filteredDoctors;
    final sorted = _sortDoctors(filtered);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Find Doctors'),
        actions: [
          PopupMenuButton<DoctorSortOption>(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Sort Doctors',
            initialValue: _currentSort,
            onSelected: (option) {
              setState(() {
                _currentSort = option;
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: DoctorSortOption.rating,
                child: Text('Highest Rated'),
              ),
              const PopupMenuItem(
                value: DoctorSortOption.experience,
                child: Text('Most Experienced'),
              ),
              const PopupMenuItem(
                value: DoctorSortOption.feeAsc,
                child: Text('Consultation Fee: Low to High'),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Search Input Field
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SearchBar(
                controller: _searchController,
                hintText: 'Search by doctor, specialty, hospital...',
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
              ),
            ),

            // Horizontal Specialty Chips Bar
            SizedBox(
              height: 48,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
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
            const SizedBox(height: 10),

            // Results count strip
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              child: Row(
                children: [
                  Text(
                    'Showing ${sorted.length} specialists',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  if (doctorProvider.selectedSpecialty != 'All' ||
                      doctorProvider.searchQuery.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        _searchController.clear();
                        doctorProvider.setSearchQuery('');
                        doctorProvider.setSpecialty('All');
                      },
                      style: TextButton.styleFrom(
                        padding: EdgeInsets.zero,
                        visualDensity: VisualDensity.compact,
                      ),
                      child: const Text('Reset Filters'),
                    ),
                ],
              ),
            ),

            // Doctor List Content with Loading & Empty States
            Expanded(
              child: _buildListContent(
                context,
                doctorProvider,
                sorted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListContent(
    BuildContext context,
    DoctorProvider provider,
    List<DoctorModel> doctors,
  ) {
    if (provider.isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline_rounded,
                  size: 48, color: AppColors.error),
              const SizedBox(height: 12),
              Text(provider.error!),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => provider.loadDoctors(),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (doctors.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.person_search_rounded,
                  size: 36,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'No Doctors Found',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const SizedBox(height: 6),
              Text(
                'No doctor matches your filter. Try adjusting your search query or selecting a different specialty.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
              const SizedBox(height: 16),
              OutlinedButton(
                onPressed: () {
                  _searchController.clear();
                  provider.setSearchQuery('');
                  provider.setSpecialty('All');
                },
                child: const Text('Clear All Filters'),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      itemCount: doctors.length,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return DoctorCard(
          doctor: doctor,
          onTap: () => _navigateToDetail(context, doctor),
          onBookVisit: () => _navigateToDetail(context, doctor),
        );
      },
    );
  }
}
