import '../models/report_model.dart';
import '../models/upvote_model.dart';

abstract class ReportsRemoteDataSource {
  Future<String> createReport(ReportModel report);

  Future<List<ReportModel>> getReports();

  Future<ReportModel?> getReportById(String reportId);

  Future<List<ReportModel>> getMyReports(String userId);

  Future<void> updateReport(ReportModel report);

  Future<void> deleteReport(String reportId);

  Future<List<UpvoteModel>> getUpvotes(String reportId);

  Future<void> toggleUpvote({required String reportId, required String userId});
}
