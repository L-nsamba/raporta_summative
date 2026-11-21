import 'package:flutter/material.dart';

import '../../../../core/enums/report_status.dart';
import '../../../reports/domain/entities/report.dart';

class ReportProgressTimeline extends StatelessWidget {
  final Report report;

  const ReportProgressTimeline({super.key, required this.report});

  // The normal report progression.
  static const List<String> _stages = [
    'Submitted',
    'Under Review',
    'Forwarded',
    'In Progress',
    'Resolved',
  ];

  // Return the index of the current stage.
  int _currentStageIndex(ReportStatus status) {
    return switch (status) {
      ReportStatus.pending => 0,
      ReportStatus.underReview => 1,
      ReportStatus.forwarded => 2,
      ReportStatus.inProgress => 3,
      ReportStatus.resolved => 4,
      ReportStatus.declined => -1,
    };
  }

  String _formatDate(DateTime date) {
    final localDate = date.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');

    return '$day/$month/${localDate.year}';
  }

  Widget _buildStage(
    BuildContext context, {
    required String title,
    required bool isReached,
    required bool isCurrent,
    required bool isLast,
    String? subtitle,
  }) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    final activeColor = scheme.primary;
    final inactiveColor = scheme.outlineVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Indicator and connecting line.
        Column(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isReached ? activeColor : scheme.surfaceContainerHighest,
              ),
              child: Icon(
                isReached ? Icons.check : Icons.circle_outlined,
                size: isReached ? 20 : 16,
                color: isReached ? scheme.onPrimary : scheme.onSurfaceVariant,
              ),
            ),

            if (!isLast)
              Container(
                width: 2,
                height: 42,
                color: isReached && !isCurrent ? activeColor : inactiveColor,
              ),
          ],
        ),

        const SizedBox(width: 16),

        // Stage information.
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 5),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        title,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontWeight: isCurrent
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: isReached
                              ? scheme.onSurface
                              : scheme.onSurfaceVariant,
                        ),
                      ),
                    ),

                    if (isCurrent) ...[
                      const SizedBox(width: 8),
                      Text(
                        'Current',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: activeColor,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ],
                ),

                if (subtitle != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDeclinedOutcome(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.cancel, color: scheme.error, size: 34),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Declined',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: scheme.error,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'This report was declined.',
                style: theme.textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDeclined = report.status == ReportStatus.declined;

    final currentIndex = _currentStageIndex(report.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Report Progress',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            if (isDeclined) ...[
              // Submission is known to have happened.
              _buildStage(
                context,
                title: 'Submitted',
                isReached: true,
                isCurrent: false,
                isLast: true,
                subtitle: _formatDate(report.createdAt),
              ),

              const SizedBox(height: 20),

              // Declined is a separate terminal outcome.
              _buildDeclinedOutcome(context),
            ] else
              for (int index = 0; index < _stages.length; index++)
                _buildStage(
                  context,
                  title: _stages[index],
                  isReached: index <= currentIndex,
                  isCurrent: index == currentIndex,
                  isLast: index == _stages.length - 1,
                  subtitle: index == 0 ? _formatDate(report.createdAt) : null,
                ),
          ],
        ),
      ),
    );
  }
}
