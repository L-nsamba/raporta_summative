import 'package:flutter/material.dart';

import '../../../../core/widgets/status_badge.dart';
import '../../../reports/domain/entities/report.dart';

class PendingReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback onViewDetails;
  final VoidCallback? onApprove;
  final VoidCallback? onDecline;

  const PendingReportCard({
    super.key,
    required this.report,
    required this.onViewDetails,
    this.onApprove,
    this.onDecline,
  });

  // Format a report's submission date using local time.
  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');

    return '$day/$month/${localDate.year}';
  }

  // Convert enum names into readable labels.
  // Example: roadDamage -> Road Damage
  String _formatCategory(String name) {
    final spaced = name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    if (spaced.isEmpty) return 'Report';

    return spaced[0].toUpperCase() + spaced.substring(1);
  }

  // Build a neutral placeholder when an image isn't available.
  Widget _imagePlaceholder(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      width: 100,
      height: 100,
      color: scheme.surfaceContainerHighest,
      alignment: Alignment.center,
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
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail or image placeholder.
                _buildImage(context),

                const SizedBox(width: 12),

                // Report information.
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      StatusBadge(status: report.status),

                      const SizedBox(height: 8),

                      Text(
                        _formatCategory(report.category.name),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),

                      const SizedBox(height: 5),

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

                      const SizedBox(height: 6),

                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 14,
                            color: scheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _formatDate(report.createdAt),
                            style: theme.textTheme.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),
            const Divider(height: 1),
            const SizedBox(height: 10),

            // Actual report identifier and details button.
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ID: ${report.reportId}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Green approval button.
                    IconButton(
                      tooltip: 'Approve report',
                      onPressed: onApprove,
                      icon: const Icon(Icons.check_circle, color: Colors.green),
                    ),

                    // Red decline button.
                    IconButton(
                      tooltip: 'Decline report',
                      onPressed: onDecline,
                      icon: const Icon(Icons.cancel, color: Colors.red),
                    ),

                    const SizedBox(width: 8),

                    // View Details button.
                    OutlinedButton.icon(
                      onPressed: onViewDetails,
                      icon: const Icon(Icons.visibility_outlined, size: 18),
                      label: const Text('View Details'),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
