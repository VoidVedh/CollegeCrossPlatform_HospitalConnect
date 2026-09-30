import 'package:flutter/material.dart';
import 'package:hospital_connect/core/theme/app_colors.dart';
import 'package:hospital_connect/core/theme/app_radius.dart';
import 'package:hospital_connect/models/models.dart';

/// Card widget for a diagnostic attachment or laboratory report file.
class RecordAttachmentCard extends StatelessWidget {
  const RecordAttachmentCard({super.key, required this.attachment});

  final RecordAttachmentModel attachment;

  IconData _getFileIcon(String fileType) {
    final lower = fileType.toLowerCase();
    if (lower.contains('pdf')) {
      return Icons.picture_as_pdf_rounded;
    } else if (lower.contains('jpg') || lower.contains('png') || lower.contains('image')) {
      return Icons.image_rounded;
    } else if (lower.contains('doc') || lower.contains('text')) {
      return Icons.description_rounded;
    }
    return Icons.insert_drive_file_rounded;
  }

  Color _getFileColor(String fileType) {
    final lower = fileType.toLowerCase();
    if (lower.contains('pdf')) {
      return AppColors.error;
    } else if (lower.contains('jpg') || lower.contains('png') || lower.contains('image')) {
      return AppColors.primary;
    }
    return AppColors.secondary;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final fileIcon = _getFileIcon(attachment.fileType);
    final fileColor = _getFileColor(attachment.fileType);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      color: colorScheme.surface,
      shape: RoundedRectangleBorder(
        borderRadius: AppRadius.roundedMd,
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: ListTile(
        leading: Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: fileColor.withValues(alpha: 0.12),
            borderRadius: AppRadius.roundedSm,
          ),
          child: Icon(fileIcon, color: fileColor, size: 24),
        ),
        title: Text(
          attachment.fileName,
          style: theme.textTheme.bodyMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${attachment.fileType.toUpperCase()} Report • Verified by Lab',
          style: theme.textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        trailing: IconButton(
          tooltip: 'View or Download Attachment',
          icon: const Icon(Icons.download_rounded),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(
                      Icons.check_circle_outline_rounded,
                      color: AppColors.surface,
                      size: 18,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Viewing ${attachment.fileName} (Offline preview)',
                      ),
                    ),
                  ],
                ),
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
          },
        ),
      ),
    );
  }
}
