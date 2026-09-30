import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/core/theme/app_spacing.dart';
import 'package:hospital_connect/providers/medical_record_provider.dart';
import 'package:hospital_connect/screens/records/record_detail_screen.dart';
import 'package:hospital_connect/screens/records/widgets/record_timeline_item.dart';
import 'package:hospital_connect/widgets/common/empty_state.dart';
import 'package:hospital_connect/widgets/common/error_state.dart';
import 'package:provider/provider.dart';

/// Medical Records Timeline and History Screen.
class RecordsScreen extends StatefulWidget {
  const RecordsScreen({super.key});

  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  String? _selectedRecordId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final provider = context.watch<MedicalRecordProvider>();
    final isWideScreen = MediaQuery.of(context).size.width >= 840;
    final records = provider.records;

    if (isWideScreen && _selectedRecordId == null && records.isNotEmpty) {
      _selectedRecordId = records.first.id;
    }

    final selectedRecord = _selectedRecordId != null
        ? records.where((r) => r.id == _selectedRecordId).firstOrNull ??
            (records.isNotEmpty ? records.first : null)
        : null;

    final listPane = _buildBody(
      context,
      provider,
      theme,
      colorScheme,
      isWideScreen: isWideScreen,
    );

    if (isWideScreen) {
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
          child: Row(
            children: [
              SizedBox(width: 380, child: listPane),
              const VerticalDivider(thickness: 1, width: 1),
              Expanded(
                child: selectedRecord != null
                    ? RecordDetailScreen(
                        key: ValueKey(selectedRecord.id),
                        record: selectedRecord,
                        isEmbedded: true,
                      )
                    : const Center(
                        child: Text('Select a medical record to view details.'),
                      ),
              ),
            ],
          ),
        ),
      );
    }

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
            child: listPane,
          ),
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    MedicalRecordProvider provider,
    ThemeData theme,
    ColorScheme colorScheme, {
    bool isWideScreen = false,
  }) {
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
            onTap: isWideScreen
                ? () {
                    setState(() {
                      _selectedRecordId = record.id;
                    });
                  }
                : null,
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
          Expanded(
            child: Column(
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
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
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
