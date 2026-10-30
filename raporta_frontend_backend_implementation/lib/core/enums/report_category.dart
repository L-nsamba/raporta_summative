enum ReportCategory {
  roads,
  power,
  water,
  sanitation,
  lighting,
  other;

  String toFirestore() => name;

  static ReportCategory fromFirestore(String value) {
    return ReportCategory.values.firstWhere(
      (category) => category.name == value,
      orElse: () => throw FormatException('Unknown report category: $value'),
    );
  }

  String get displayName {
    switch (this) {
      case ReportCategory.roads:
        return 'Roads';
      case ReportCategory.power:
        return 'Power';
      case ReportCategory.water:
        return 'Water';
      case ReportCategory.sanitation:
        return 'Sanitation';
      case ReportCategory.lighting:
        return 'Lighting';
      case ReportCategory.other:
        return 'Other';
    }
  }
}
