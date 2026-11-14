import '../../../reports/domain/repositories/reports_repository.dart';
import '../../../../core/enums/report_status.dart';
import '../entities/citizen_dashboard_stats.dart';

class GetCitizenDashboard {
  final ReportsRepository repository;

  const GetCitizenDashboard(this.repository);

  Future<CitizenDashboardStats> call({
    required String userId,
    required String areaId,
  }) async {
    // Only approved, publicly visible reports.
    final reports = await repository.getPublicReports();

    // Public reports belonging to the citizen's registered area.
    final areaReports = reports
        .where((report) => report.areaId == areaId)
        .toList();

    // Total public reports in the area.
    final totalReportsInArea = areaReports.length;

    // Resolved public reports in the area.
    final resolvedReportsInArea = areaReports
        .where((report) => report.status == ReportStatus.resolved)
        .length;

    // Approved reports that are still being processed.
    final activeReportsInArea = areaReports
        .where(
          (report) =>
              report.status == ReportStatus.underReview ||
              report.status == ReportStatus.forwarded ||
              report.status == ReportStatus.inProgress,
        )
        .length;

    // All reports submitted by the citizen, regardless of
    // area or publication status.
    final myReports = await repository.getMyReports(userId);

    // Five most recent public reports in the citizen's area.
    areaReports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return CitizenDashboardStats(
      totalReportsInArea: totalReportsInArea,
      resolvedReportsInArea: resolvedReportsInArea,
      activeReportsInArea: activeReportsInArea,
      myReports: myReports.length,
      latestReports: areaReports.take(5).toList(),
    );
  }
}
