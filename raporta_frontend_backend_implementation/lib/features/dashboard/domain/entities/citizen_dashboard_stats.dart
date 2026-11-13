import '../../../reports/domain/entities/report.dart';

class CitizenDashboardStats {
  final int totalReportsInArea;
  final int resolvedReportsInArea;
  final int activeReportsInArea;
  final int myReports;
  final List<Report> latestReports;

  const CitizenDashboardStats({
    required this.totalReportsInArea,
    required this.resolvedReportsInArea,
    required this.activeReportsInArea,
    required this.myReports,
    required this.latestReports,
  });
}
