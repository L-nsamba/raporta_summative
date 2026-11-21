import 'package:flutter/material.dart';

import '../../../../core/widgets/status_badge.dart';
import '../../../reports/domain/entities/report.dart';

class ReportInformationSection extends StatelessWidget {
  final Report report;
  final String? areaName;

  const ReportInformationSection({
    super.key,
    required this.report,
    this.areaName,
  });

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    const months = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${localDate.day} '
        '${months[localDate.month - 1]} '
        '${localDate.year}';
  }

  Widget _imagePlaceholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      height: 220,
      width: double.infinity,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
      child: Icon(
        Icons.image_not_supported_outlined,
        size: 56,
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildReportImage(BuildContext context) {
    final photoUrl = report.photoUrl?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: photoUrl == null || photoUrl.isEmpty
          ? _imagePlaceholder(context)
          : Image.network(
              photoUrl,
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) {
                if (progress == null) return child;

                return const SizedBox(
                  height: 220,
                  child: Center(child: CircularProgressIndicator()),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return _imagePlaceholder(context);
              },
            ),
    );
  }

  Widget _informationRow({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String value,
  }) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: theme.colorScheme.onSurfaceVariant),

        const SizedBox(width: 12),

        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),

              const SizedBox(height: 4),

              Text(value, style: theme.textTheme.bodyMedium),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. REPORT PHOTO
        _buildReportImage(context),

        const SizedBox(height: 20),

        // 2. CATEGORY AND STATUS
        Text(
          report.category.displayName,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        StatusBadge(status: report.status),

        const SizedBox(height: 12),

        // 3. ACTUAL REPORT ID
        SelectableText(
          'Report ID: ${report.reportId}',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),

        const SizedBox(height: 20),

        const Divider(),

        const SizedBox(height: 16),

        // 4. DESCRIPTION
        Text('Description', style: theme.textTheme.titleMedium),

        const SizedBox(height: 8),

        Text(report.description, style: theme.textTheme.bodyMedium),

        const SizedBox(height: 24),

        // 5. AREA NAME
        _informationRow(
          context: context,
          icon: Icons.location_city_outlined,
          title: 'Area',
          value: areaName ?? 'Area unavailable',
        ),

        const SizedBox(height: 20),

        // 6. LOCATION DESCRIPTION
        _informationRow(
          context: context,
          icon: Icons.location_on_outlined,
          title: 'Location',
          value: report.locationDescription,
        ),

        const SizedBox(height: 20),

        // 7. SUBMISSION DATE
        _informationRow(
          context: context,
          icon: Icons.calendar_today_outlined,
          title: 'Submitted On',
          value: _formatDate(report.createdAt),
        ),
      ],
    );
  }
}
