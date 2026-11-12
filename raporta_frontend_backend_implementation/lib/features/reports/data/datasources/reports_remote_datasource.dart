import 'package:raporta_frontend_backend_implementation/core/enums/decline_reason.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';

import '../models/report_model.dart';
import '../models/upvote_model.dart';

abstract class ReportsRemoteDataSource {
  Future<String> createReport(ReportModel report);

  Future<List<ReportModel>> getReports();

  Future<ReportModel?> getReportById(String reportId);

  Future<List<ReportModel>> getMyReports(String userId);

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
  
  Future<void> deleteReport(String reportId);

  Future<List<UpvoteModel>> getUpvotes(String reportId);

  Future<void> toggleUpvote({required String reportId, required String userId});
}
