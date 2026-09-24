import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/utils/formatters.dart';
import 'package:hospital_connect/models/models.dart';

/// Small, reusable, accessible Doctor Card component with specialty badge and rating UI.
class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    required this.onTap,
    required this.onBookVisit,
  });

  final DoctorModel doctor;
  final VoidCallback onTap;
  final VoidCallback onBookVisit;

  Color _getSpecialtyColor(String specialty) {
    switch (specialty.toLowerCase()) {
      case 'cardiology':
        return const Color(0xFFC62828); // Rich crimson/red
      case 'neurology':
        return const Color(0xFF6A1B9A); // Deep purple
      case 'pediatrics':
        return const Color(0xFFE65100); // Warm orange
      case 'orthopedics':
        return const Color(0xFF00695C); // Deep teal/cyan
      case 'general medicine':
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final specialtyColor = _getSpecialtyColor(doctor.specialty);
    final initials = doctor.name
        .split(' ')
        .where((part) => part.isNotEmpty && part != 'Dr.')
        .map((part) => part[0])
        .take(2)
        .join();

    return Semantics(
      button: true,
      label:
          'Doctor ${doctor.name}, ${doctor.specialty}, Rating ${doctor.rating}, Fee ${AppFormatters.formatCurrency(doctor.consultationFee)}',
      child: Card(
        margin: const EdgeInsets.symmetric(vertical: 6),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: colorScheme.outlineVariant),
        ),
        color: colorScheme.surface,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Top row: Initials Avatar, Doctor Name, Specialty badge
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 26,
                      backgroundColor:
                          specialtyColor.withValues(alpha: 0.12),
                      child: Text(
                        initials.isEmpty ? 'DR' : initials,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: specialtyColor,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            doctor.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          // Specialty Chip Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: specialtyColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              doctor.specialty,
                              style: theme.textTheme.labelSmall?.copyWith(
                                color: specialtyColor,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Rating block
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFEF3C7),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.star_rounded,
                            size: 16,
                            color: Color(0xFFD97706),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            doctor.rating.toStringAsFixed(1),
                            style: theme.textTheme.labelMedium?.copyWith(
                              color: const Color(0xFF92400E),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Experience & Hospital address info
                Row(
                  children: [
                    Icon(
                      Icons.work_outline_rounded,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${doctor.experienceYears} yrs experience',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Icon(
                      Icons.local_hospital_outlined,
                      size: 15,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        doctor.hospitalName,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                const Divider(height: 1),
                const SizedBox(height: 12),

                // Bottom row: Fee and Action buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consultation Fee',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: colorScheme.onSurfaceVariant,
                            fontSize: 10,
                          ),
                        ),
                        Text(
                          AppFormatters.formatCurrency(doctor.consultationFee),
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: colorScheme.primary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        OutlinedButton(
                          onPressed: onTap,
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            minimumSize: const Size(48, 40),
                          ),
                          child: const Text('Profile'),
                        ),
                        const SizedBox(width: 8),
                        FilledButton(
                          onPressed: onBookVisit,
                          style: FilledButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            minimumSize: const Size(48, 40),
                          ),
                          child: const Text('Book Visit'),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
