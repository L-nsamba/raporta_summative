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
    final reports = await repository.getReports();

    // Reports belonging to the citizen's registered area.
    final areaReports = reports
        .where((report) => report.areaId == areaId)
        .toList();

    // Total reports in the area.
    final totalReportsInArea = areaReports.length;

    // Resolved reports in the area.
    final resolvedReportsInArea = areaReports
        .where((report) => report.status == ReportStatus.resolved)
        .length;

    // Reports that are still being processed.
    final activeReportsInArea = areaReports
        .where(
          (report) =>
              report.status == ReportStatus.pending ||
              report.status == ReportStatus.underReview ||
              report.status == ReportStatus.forwarded ||
              report.status == ReportStatus.inProgress,
        )
        .length;

    // Reports submitted by the citizen, regardless of area.
    final myReports = await repository.getMyReports(userId);

    // Five most recent reports in the citizen's area.
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
