import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/widgets/specialty_chip.dart';

/// Horizontal list of selectable specialty category chips.
class SpecialtyChipsRow extends StatelessWidget {
  const SpecialtyChipsRow({
    super.key,
    required this.selectedSpecialty,
    required this.onSpecialtySelected,
  });

  final String selectedSpecialty;
  final ValueChanged<String> onSpecialtySelected;

  static const List<Map<String, dynamic>> specialties = [
    {'label': 'All', 'icon': Icons.medical_services_rounded},
    {'label': 'Cardiology', 'icon': Icons.favorite_rounded},
    {'label': 'Neurology', 'icon': Icons.psychology_rounded},
    {'label': 'Pediatrics', 'icon': Icons.child_care_rounded},
    {'label': 'Orthopedics', 'icon': Icons.accessibility_new_rounded},
    {'label': 'General Medicine', 'icon': Icons.local_hospital_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: specialties.length,
        separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final item = specialties[index];
          final label = item['label'] as String;
          final icon = item['icon'] as IconData;
          final isSelected = selectedSpecialty.toLowerCase() == label.toLowerCase();

          return SpecialtyChip(
            label: label,
            icon: icon,
            isSelected: isSelected,
            onTap: () => onSpecialtySelected(label),
          );
        },
      ),
    );
  }
}
