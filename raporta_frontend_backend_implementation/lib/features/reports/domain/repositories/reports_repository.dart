import 'package:raporta_frontend_backend_implementation/core/enums/decline_reason.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/upvotes.dart';

abstract class ReportsRepository {
  // Creation of a new report
  Future<String> createReport(Report report);

  // Retrieve all reports
  Future<List<Report>> getReports();

  // Retrieve a specific report
  Future<Report?> getReportById(String reportId);

  // Retrieve reports submitted by a particular citizen
  Future<List<Report>> getMyReports(String userId);

  // Update report information
  Future<void> updateReportStatus({
    required String reportId,
    required ReportStatus status,
  });

  Future<void> forwardReport({
    required String reportId,
    required String agencyId,
  });

  Future<void> declineReport({
    required String reportId,
    required DeclineReason reason,
    String? feedback,
  });

  // Soft delete a report
  Future<void> deleteReport(String reportId);

  // Retrieve upvotes for a report
  Future<List<Upvote>> getUpvotes(String reportId);

  // Add or remove a user's upvote
  Future<void> toggleUpvote({required String reportId, required String userId});
}
