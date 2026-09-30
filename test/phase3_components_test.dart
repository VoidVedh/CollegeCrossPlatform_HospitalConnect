import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/core/theme/app_theme.dart';
import 'package:hospital_connect/models/enums.dart';
import 'package:hospital_connect/widgets/common/common_widgets.dart';

void main() {
  group('Phase 3 Shared Design Tokens & Widgets', () {
    test('AppSpacing and AppRadius define standard scale', () {
      expect(AppSpacing.xs, 4.0);
      expect(AppSpacing.sm, 8.0);
      expect(AppSpacing.md, 12.0);
      expect(AppSpacing.lg, 16.0);
      expect(AppSpacing.xl, 20.0);
      expect(AppSpacing.xxl, 24.0);

      expect(AppRadius.sm, 8.0);
      expect(AppRadius.md, 12.0);
      expect(AppRadius.lg, 16.0);
      expect(AppRadius.full, 999.0);
    });

    test('DoctorAvatar extracts clean initials from diverse name formats', () {
      expect(DoctorAvatar.getInitials('Dr. Ananya Sharma'), 'AS');
      expect(DoctorAvatar.getInitials('Dr Rajesh'), 'R');
      expect(DoctorAvatar.getInitials('Aditya Sharma'), 'AS');
      expect(DoctorAvatar.getInitials('Dr. Sarah Jenkins MD'), 'SJ');
      expect(DoctorAvatar.getInitials(''), 'DR');
    });

    testWidgets('DoctorAvatar renders with hero animation and fallback text',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: const Scaffold(
            body: DoctorAvatar(
              name: 'Dr. Anand Raman',
              heroTag: 'doc-avatar-1',
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('AR'), findsOneWidget);
      expect(find.byType(Hero), findsOneWidget);
    });

    testWidgets('StatusBadge renders for appointment and bill statuses',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: Scaffold(
            body: Column(
              children: [
                StatusBadge.fromAppointmentStatus(AppointmentStatus.upcoming),
                StatusBadge.fromAppointmentStatus(AppointmentStatus.cancelled),
                StatusBadge.fromBillStatus(BillStatus.paid),
                StatusBadge.fromBillStatus(BillStatus.pending),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Upcoming'), findsOneWidget);
      expect(find.text('Cancelled'), findsOneWidget);
      expect(find.text('Paid'), findsOneWidget);
      expect(find.text('Pending'), findsOneWidget);
    });

    testWidgets('SectionHeader triggers callback on action press',
        (tester) async {
      bool actionTapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: Scaffold(
            body: SectionHeader(
              title: 'Top Doctors',
              subtitle: 'Consult verified specialists',
              actionLabel: 'See All',
              onAction: () => actionTapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Top Doctors'), findsOneWidget);
      expect(find.text('Consult verified specialists'), findsOneWidget);
      expect(find.text('See All'), findsOneWidget);

      await tester.tap(find.text('See All'));
      expect(actionTapped, isTrue);
    });

    testWidgets('EmptyState displays icon, title, message, and button',
        (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: Scaffold(
            body: EmptyState(
              icon: Icons.calendar_today_outlined,
              title: 'No Appointments Found',
              message: 'You have no scheduled consultations yet.',
              actionLabel: 'Book Doctor',
              onAction: () => tapped = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('No Appointments Found'), findsOneWidget);
      expect(find.text('You have no scheduled consultations yet.'),
          findsOneWidget);
      expect(find.text('Book Doctor'), findsOneWidget);

      await tester.tap(find.text('Book Doctor'));
      expect(tapped, isTrue);
    });

    testWidgets('ErrorState shows message and triggers onRetry', (tester) async {
      bool retried = false;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: Scaffold(
            body: ErrorState(
              message: 'Failed to fetch medical records.',
              onRetry: () => retried = true,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Failed to fetch medical records.'), findsOneWidget);
      expect(find.text('Try Again'), findsOneWidget);

      await tester.tap(find.text('Try Again'));
      expect(retried, isTrue);
    });

    testWidgets('InfoRow and AmountRow render labels and values',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: const Scaffold(
            body: Column(
              children: [
                InfoRow(
                  label: 'Appointment Date',
                  value: '15 Oct 2026',
                  icon: Icons.calendar_month,
                ),
                AmountRow(
                  label: 'Consultation Charges',
                  amount: 800.0,
                ),
                AmountRow(
                  label: 'Total Payable',
                  amount: 944.0,
                  isTotal: true,
                ),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Appointment Date'), findsOneWidget);
      expect(find.text('15 Oct 2026'), findsOneWidget);
      expect(find.text('Consultation Charges'), findsOneWidget);
      expect(find.text('Total Payable'), findsOneWidget);
    });

    testWidgets('LoadingSkeleton renders with animation controller',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.light(useGoogleFonts: false),
          home: const Scaffold(
            body: LoadingSkeleton(width: 120, height: 20),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 500));
      expect(find.byType(LoadingSkeleton), findsOneWidget);
    });
  });
}
