enum DeclineReason {
  duplicate,
  unrelated,
  alreadyResolved,
  other;

  String toFirestore() {
    switch (this) {
      case DeclineReason.duplicate:
        return 'duplicate';
      case DeclineReason.unrelated:
        return 'unrelated';
      case DeclineReason.alreadyResolved:
        return 'already_resolved';
      case DeclineReason.other:
        return 'other';
    }
  }

  static DeclineReason fromFirestore(String value) {
    return DeclineReason.values.firstWhere(
      (reason) => reason.toFirestore() == value,
      orElse: () => throw FormatException(
        'Unknown decline reason: $value',
      ),
    );
  }
}
