enum ReportStatus {
  pending,
  underReview,
  forwarded,
  inProgress,
  resolved,
  declined;

  String toFirestore() {
    switch (this) {
      case ReportStatus.pending:
        return 'pending';
      case ReportStatus.underReview:
        return 'under_review';
      case ReportStatus.forwarded:
        return 'forwarded';
      case ReportStatus.inProgress:
        return 'in_progress';
      case ReportStatus.resolved:
        return 'resolved';
      case ReportStatus.declined:
        return 'declined';
    }
  }

  static ReportStatus fromFirestore(String value) {
    return ReportStatus.values.firstWhere(
      (status) => status.toFirestore() == value,
      orElse: () => throw FormatException('Unknown report status: $value'),
    );
  }
}
