import '../../../reports/domain/repositories/reports_repository.dart';
import '../../../../core/enums/report_status.dart';
import '../entities/official_dashboard_stats.dart';
import '../entities/daily_report_count.dart';

class GetOfficialDashboard {
  final ReportsRepository repository;

  const GetOfficialDashboard(this.repository);

  Future<OfficialDashboardStats> call({DateTime? now}) async {
    final reports = await repository.getReports();

    final pendingReports = reports
        .where((report) => report.status == ReportStatus.pending)
        .length;

    final underReviewReports = reports
        .where((report) => report.status == ReportStatus.underReview)
        .length;

    final forwardedReports = reports
        .where((report) => report.status == ReportStatus.forwarded)
        .length;

    final resolvedReports = reports
        .where((report) => report.status == ReportStatus.resolved)
        .length;

    // Determine the start of the current calendar week.
    final currentDate = (now ?? DateTime.now()).toLocal();

    final startOfWeek = DateTime(
      currentDate.year,
      currentDate.month,
      currentDate.day - (currentDate.weekday - DateTime.monday),
    );

    // Generate Monday through Sunday report counts.
    final weeklyReports = List.generate(7, (index) {
      final day = DateTime(
        startOfWeek.year,
        startOfWeek.month,
        startOfWeek.day + index,
      );

      final nextDay = DateTime(day.year, day.month, day.day + 1);

      final count = reports.where((report) {
        final createdAt = report.createdAt.toLocal();

        return !createdAt.isBefore(day) && createdAt.isBefore(nextDay);
      }).length;

      return DailyReportCount(date: day, count: count);
    });

    // Copy before sorting to avoid modifying the repository's list.
    final latestReports = [...reports]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return OfficialDashboardStats(
      pendingReports: pendingReports,
      underReviewReports: underReviewReports,
      forwardedReports: forwardedReports,
      resolvedReports: resolvedReports,
      weeklyReports: weeklyReports,
      latestReports: latestReports.take(5).toList(),
    );
  }
}
