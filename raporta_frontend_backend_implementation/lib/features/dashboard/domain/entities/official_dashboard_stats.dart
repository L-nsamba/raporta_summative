import '../../../reports/domain/entities/report.dart';
import 'daily_report_count.dart';

class OfficialDashboardStats {
  final int pendingReports;
  final int underReviewReports;
  final int forwardedReports;
  final int resolvedReports;

  final List<DailyReportCount> weeklyReports;
  final List<Report> latestReports;

  const OfficialDashboardStats({
    required this.pendingReports,
    required this.underReviewReports,
    required this.forwardedReports,
    required this.resolvedReports,
    required this.weeklyReports,
    required this.latestReports,
  });
}
