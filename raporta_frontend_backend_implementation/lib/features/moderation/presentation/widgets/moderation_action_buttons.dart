import 'package:flutter/material.dart';

import '../../../../core/enums/report_status.dart';

class ModerationActionButtons extends StatelessWidget {
  final ReportStatus status;
  final bool isSubmitting;

  final VoidCallback onApprove;
  final VoidCallback onDecline;
  final VoidCallback onForward;
  final VoidCallback onMarkInProgress;
  final VoidCallback onMarkResolved;

  const ModerationActionButtons({
    super.key,
    required this.status,
    required this.isSubmitting,
    required this.onApprove,
    required this.onDecline,
    required this.onForward,
    required this.onMarkInProgress,
    required this.onMarkResolved,
  });

  @override
  Widget build(BuildContext context) {
    if (status == ReportStatus.resolved || status == ReportStatus.declined) {
      return const SizedBox.shrink();
    }

    Widget primaryAction(String label, VoidCallback action) {
      return FilledButton(
        onPressed: isSubmitting ? null : action,
        child: Text(label),
      );
    }

    Widget declineAction() {
      return OutlinedButton(
        onPressed: isSubmitting ? null : onDecline,
        child: const Text('Decline'),
      );
    }

    final Widget mainButton = switch (status) {
      ReportStatus.pending => primaryAction('Approve', onApprove),

      ReportStatus.underReview => primaryAction('Forward to Agency', onForward),

      ReportStatus.forwarded => primaryAction(
        'Mark In Progress',
        onMarkInProgress,
      ),

      ReportStatus.inProgress => primaryAction('Mark Resolved', onMarkResolved),

      ReportStatus.resolved || ReportStatus.declined => const SizedBox.shrink(),
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Moderation Actions',
          style: Theme.of(context).textTheme.titleLarge,
        ),

        const SizedBox(height: 16),

        mainButton,

        const SizedBox(height: 8),

        declineAction(),
      ],
    );
  }
}
