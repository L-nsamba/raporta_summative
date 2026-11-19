import 'package:flutter/material.dart';
import 'package:raporta_frontend_backend_implementation/core/widgets/report_thumbnail.dart';

import '../../features/reports/domain/entities/report.dart';
import 'status_badge.dart';

class ReportCard extends StatelessWidget {
  final Report report;
  final VoidCallback? onTap;

  const ReportCard({super.key, required this.report, this.onTap});

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');

    return '$day/$month/${date.year}';
  }

  String _formatCategory(String category) {
    final formatted = category.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Report photo or default placeholder.
              ReportThumbnail(photoUrl: report.photoUrl, size: 96),

              const SizedBox(width: 12),

              // Report information.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Category and status.
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            _formatCategory(report.category.name),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                        const SizedBox(width: 6),

                        StatusBadge(status: report.status),
                      ],
                    ),

                    const SizedBox(height: 8),

                    // Description.
                    Text(
                      report.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall,
                    ),

                    const SizedBox(height: 10),

                    // Location.
                    Row(
                      children: [
                        Icon(
                          Icons.location_on_outlined,
                          size: 15,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            report.locationDescription.trim().isNotEmpty
                                ? report.locationDescription
                                : report.areaId,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 6),

                    // Submission date.
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today_outlined,
                          size: 13,
                          color: theme.colorScheme.onSurfaceVariant,
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
        ),
      ),
    );
  }
}
