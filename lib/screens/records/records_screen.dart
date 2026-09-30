import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/providers/medical_record_provider.dart';
import 'package:hospital_connect/screens/records/widgets/record_timeline_item.dart';
import 'package:hospital_connect/widgets/common/empty_state.dart';
import 'package:hospital_connect/widgets/common/error_state.dart';
import 'package:provider/provider.dart';

/// Medical Records Timeline and History Screen.
class RecordsScreen extends StatelessWidget {
  const RecordsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<MedicalRecordProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Medical Records'),
        actions: [
          IconButton(
            tooltip: 'Refresh Records',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () => context.read<MedicalRecordProvider>().loadRecords(),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: _buildBody(context, provider, theme, colorScheme),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MedicalRecordProvider provider,
    ThemeData theme,
    ColorScheme colorScheme,
  ) {
    if (provider.isLoading && provider.records.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (provider.error != null && provider.records.isEmpty) {
      return ErrorState(
        title: 'Unable to load medical records',
        message: provider.error!,
        onRetry: () => provider.loadRecords(),
      );
    }

    final records = provider.records;

    if (records.isEmpty) {
      return const EmptyState(
        icon: Icons.folder_open_rounded,
        title: 'No Medical Records Found',
        message:
            'Completed consultations and lab reports will appear on this timeline.',
      );
    }

    return RefreshIndicator(
      onRefresh: () => provider.loadRecords(),
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        itemCount: records.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildHeader(theme, colorScheme, records.length);
          }

          final record = records[index - 1];
          final isLast = index == records.length;

          return RecordTimelineItem(
            record: record,
            isLast: isLast,
          );
        },
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, ColorScheme colorScheme, int count) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Clinical Visit Timeline',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.xxs),
              Text(
                'Chronological medical history & diagnostics',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.sm + 2,
              vertical: AppSpacing.xs + 2,
            ),
            decoration: const BoxDecoration(
              color: AppColors.primaryContainer,
              borderRadius: AppRadius.roundedMd,
            ),
            child: Text(
              '$count Records',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
