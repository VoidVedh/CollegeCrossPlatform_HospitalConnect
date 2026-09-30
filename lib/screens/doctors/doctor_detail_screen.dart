import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/models/models.dart';
import 'package:hospital_connect/providers/doctor_provider.dart';
import 'package:hospital_connect/screens/appointments/booking_screen.dart';
import 'package:hospital_connect/screens/doctors/widgets/doctor_booking_bar.dart';
import 'package:hospital_connect/screens/doctors/widgets/doctor_clinic_location.dart';
import 'package:hospital_connect/screens/doctors/widgets/doctor_metrics_row.dart';
import 'package:hospital_connect/screens/doctors/widgets/doctor_review_card.dart';
import 'package:hospital_connect/widgets/common/doctor_avatar.dart';
import 'package:provider/provider.dart';

/// Doctor Detail view presenting bio, experience, reviews, clinic address, and fees.
class DoctorDetailScreen extends StatelessWidget {
  const DoctorDetailScreen({
    super.key,
    DoctorModel? doctor,
    this.doctorId,
    this.isEmbedded = false,
  })  : initialDoctor = doctor,
        assert(doctor != null || doctorId != null,
            'Either doctor or doctorId must be provided');

  final DoctorModel? initialDoctor;
  final String? doctorId;
  final bool isEmbedded;

  Color _getSpecialtyColor(String specialty) {
    switch (specialty.toLowerCase()) {
      case 'cardiology':
        return AppColors.specialtyCardiology;
      case 'neurology':
        return AppColors.specialtyNeurology;
      case 'pediatrics':
        return AppColors.specialtyPediatrics;
      case 'orthopedics':
        return AppColors.specialtyOrthopedics;
      case 'general medicine':
      default:
        return AppColors.primary;
    }
  }

  void _navigateToBooking(BuildContext context, DoctorModel activeDoctor) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BookingScreen(doctor: activeDoctor),
        settings: const RouteSettings(name: '/booking'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final doctorProvider = context.watch<DoctorProvider>();
    final activeDoctor = (doctorId != null
            ? doctorProvider.getDoctorById(doctorId!)
            : null) ??
        initialDoctor ??
        (initialDoctor != null
            ? doctorProvider.getDoctorById(initialDoctor!.id)
            : null);

    if (activeDoctor == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Doctor Profile')),
        body: const Center(child: Text('Doctor details not found.')),
      );
    }
    final DoctorModel doctor = activeDoctor;
    final specialtyColor = _getSpecialtyColor(doctor.specialty);

    final content = ListView(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      children: [
        // 1. Doctor Header Card
        _buildDoctorHeaderCard(theme, colorScheme, doctor, specialtyColor),
        const SizedBox(height: AppSpacing.lg),

        // 2. Statistics Counter Strip
        DoctorMetricsRow(doctor: doctor),
        const SizedBox(height: AppSpacing.xl),

        // 3. About Doctor Bio
        Text(
          'About Doctor',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          doctor.about,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        // 4. Clinic Address Card
        DoctorClinicLocation(doctor: doctor),
        const SizedBox(height: AppSpacing.xl),

        // 5. Patient Reviews Section
        _buildReviewsSection(context, theme, colorScheme, doctor),
        const SizedBox(height: AppSpacing.xxl),
      ],
    );

    if (isEmbedded) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.lg,
              vertical: AppSpacing.sm + 2,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Doctor Profile',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Share Doctor Profile',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Doctor profile link copied for ${doctor.name}'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(child: content),
          DoctorBookingBar(
            doctor: doctor,
            onBookPressed: () => _navigateToBooking(context, doctor),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Doctor Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            tooltip: 'Share Doctor Profile',
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Doctor profile link copied for ${doctor.name}'),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: content,
      ),
      bottomNavigationBar: DoctorBookingBar(
        doctor: doctor,
        onBookPressed: () => _navigateToBooking(context, doctor),
      ),
    );
  }

  Widget _buildDoctorHeaderCard(
    ThemeData theme,
    ColorScheme colorScheme,
    DoctorModel doctor,
    Color specialtyColor,
  ) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg + 2),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: AppRadius.roundedXl,
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          DoctorAvatar(
            name: doctor.name,
            radius: 36,
            heroTag: 'doctor_avatar_${doctor.id}',
            backgroundColor: specialtyColor.withValues(alpha: 0.12),
            foregroundColor: specialtyColor,
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.name,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs + 2),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.xs,
                  ),
                  decoration: BoxDecoration(
                    color: specialtyColor.withValues(alpha: 0.1),
                    borderRadius: AppRadius.roundedSm,
                  ),
                  child: Text(
                    doctor.specialty,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: specialtyColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xs + 2),
                Text(
                  doctor.hospitalName,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewsSection(
    BuildContext context,
    ThemeData theme,
    ColorScheme colorScheme,
    DoctorModel doctor,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Patient Reviews (${doctor.reviews.length})',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              '${doctor.rating} out of 5',
              style: theme.textTheme.bodySmall?.copyWith(
                color: AppColors.starRating,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        if (doctor.reviews.isEmpty)
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Center(
              child: Text(
                'No reviews yet for this doctor.',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          )
        else
          ...doctor.reviews.map((review) => DoctorReviewCard(review: review)),
      ],
    );
  }
}
