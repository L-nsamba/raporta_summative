import 'package:flutter/material.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/report.dart';

class StatusInformation extends StatelessWidget {
  final Report report;

  const StatusInformation({super.key, required this.report});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Only show decline feedback when the report was declined.
    final isDeclined = report.status.name == 'declined';

    final hasFeedback =
        report.declineFeedback != null &&
        report.declineFeedback!.trim().isNotEmpty;

    if (!isDeclined && report.status.name != 'pending') {
      return const SizedBox.shrink();
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isDeclined ? Icons.info_outline : Icons.hourglass_empty_outlined,
              color: isDeclined
                  ? theme.colorScheme.error
                  : theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    isDeclined ? 'Report Declined' : 'Awaiting Official Review',
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    isDeclined
                        ? hasFeedback
                              ? report.declineFeedback!
                              : 'This report was declined by an official.'
                        : 'Your report has been submitted '
                              'and is awaiting official review.',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
