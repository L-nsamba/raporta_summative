import 'package:flutter/material.dart';

import '../enums/report_status.dart';

class StatusBadge extends StatelessWidget {
  final ReportStatus status;

  const StatusBadge({super.key, required this.status});

  Color _getColor() {
    switch (status) {
      case ReportStatus.pending:
        return Colors.orange;

      case ReportStatus.underReview:
        return Colors.blue;

      case ReportStatus.forwarded:
        return Colors.indigo;

      case ReportStatus.inProgress:
        return Colors.purple;

      case ReportStatus.resolved:
        return Colors.green;

      case ReportStatus.declined:
        return Colors.red;
    }
  }

  String _getLabel() {
    switch (status) {
      case ReportStatus.pending:
        return 'Pending';

      case ReportStatus.underReview:
        return 'Under Review';

      case ReportStatus.forwarded:
        return 'Forwarded';

      case ReportStatus.inProgress:
        return 'In Progress';

      case ReportStatus.resolved:
        return 'Resolved';

      case ReportStatus.declined:
        return 'Declined';
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _getColor();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        _getLabel(),
        style: TextStyle(
          color: color,
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
