import 'package:flutter/material.dart';

import '../../../../core/widgets/status_badge.dart';
import '../../../reports/domain/entities/report.dart';

class ApprovedReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onViewDetails;

  const ApprovedReportCard({
    super.key,
    required this.report,
    required this.onViewDetails,
  });

  // Format the submission date.
  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');

    return '$day/$month/${localDate.year}';
  }

  // Show a neutral placeholder when no image is available.
  Widget _imagePlaceholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 100,
      height: 100,
      alignment: Alignment.center,
      color: scheme.surfaceContainerHighest,
      child: Icon(
        Icons.image_outlined,
        size: 36,
        color: scheme.onSurfaceVariant,
      ),
    );
  }

  Widget _buildImage(BuildContext context) {
    final url = report.photoUrl?.trim();

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: url == null || url.isEmpty
          ? _imagePlaceholder(context)
          : Image.network(
              url,
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _imagePlaceholder(context);
              },
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onViewDetails,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Report image or fallback.
                  _buildImage(context),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Category heading.
                        Text(
                          report.category.displayName,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(height: 8),

                        // Current status.
                        StatusBadge(status: report.status),

                        const SizedBox(height: 8),

                        Text(
                          report.description,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),

                        const SizedBox(height: 10),

                        Row(
                          children: [
                            Icon(
                              Icons.location_on_outlined,
                              size: 15,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                report.locationDescription,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 8),

                        Row(
                          children: [
                            Icon(
                              Icons.calendar_today_outlined,
                              size: 14,
                              color: scheme.onSurfaceVariant,
                            ),
                            const SizedBox(width: 5),
                            Flexible(
                              child: Text(
                                _formatDate(report.createdAt),
                                style: theme.textTheme.bodySmall,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),
              const Divider(height: 1),
              const SizedBox(height: 8),

              // Footer: report ID and View Details.
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'ID: ${report.reportId}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ),

                  const SizedBox(width: 8),

                  TextButton.icon(
                    onPressed: onViewDetails,
                    icon: const Icon(Icons.visibility_outlined, size: 18),
                    label: const Text('View Details'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
