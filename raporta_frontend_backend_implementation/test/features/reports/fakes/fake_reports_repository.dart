import 'package:raporta_frontend_backend_implementation/core/enums/decline_reason.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/upvotes.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/repositories/reports_repository.dart';

class FakeReportsRepository implements ReportsRepository {
  String? generatedReportId = 'report_123';

  bool shouldThrowError = false;
  bool shouldThrowGetMyReportsError = false;
  bool shouldThrowGetReportError = false;
  bool shouldThrowGetUpvotesError = false;
  bool shouldThrowToggleUpvoteError = false;
  bool shouldThrowUpdateStatusError = false;
  bool shouldThrowForwardError = false;
  bool shouldThrowDeclineError = false;
  bool shouldThrowDeleteReportError = false;
  String? deletedReportId;

  List<Report> myReports = [];
  List<Upvote> upvotes = [];
  Report? reportToReturn;

  int getMyReportsCallCount = 0;
  int getReportByIdCallCount = 0;
  int getUpvotesCallCount = 0;
  int toggleUpvoteCallCount = 0;
  int updateStatusCallCount = 0;
  int forwardReportCallCount = 0;
  int declineReportCallCount = 0;
  int createReportCallCount = 0;
  Report? lastCreatedReport;

  String? lastUpdatedReportId;
  ReportStatus? lastStatus;

  String? lastForwardedReportId;
  String? lastAgencyId;

  String? lastDeclinedReportId;
  DeclineReason? lastDeclineReason;
  String? lastDeclineFeedback;

  @override
  Future<String> createReport(Report report) async {
    createReportCallCount++;
    lastCreatedReport = report;

    if (shouldThrowError) {
      throw Exception('Failed to create report');
    }

    return generatedReportId!;
  }

  @override
  Future<List<Report>> getReports() async => [];

  @override
  Future<List<Report>> getPublicReports() async => [];

  @override
  Future<Report?> getReportById(String reportId) async {
    getReportByIdCallCount++;

    if (shouldThrowGetReportError) {
      throw Exception('Failed to retrieve report');
    }

    return reportToReturn;
  }

  @override
  Future<List<Report>> getMyReports(String userId) async {
    getMyReportsCallCount++;

    if (shouldThrowGetMyReportsError) {
      throw Exception('Failed to retrieve reports');
    }

    return myReports;
  }

  @override
  Future<List<Upvote>> getUpvotes(String reportId) async {
    getUpvotesCallCount++;

    if (shouldThrowGetUpvotesError) {
      throw Exception('Failed to retrieve upvotes');
    }

    return upvotes;
  }

  @override
  Future<void> toggleUpvote({
    required String reportId,
    required String userId,
  }) async {
    toggleUpvoteCallCount++;

    if (shouldThrowToggleUpvoteError) {
      throw Exception('Failed to toggle upvote');
    }

    final existingIndex = upvotes.indexWhere(
      (upvote) => upvote.userId == userId,
    );

    if (existingIndex >= 0) {
      upvotes.removeAt(existingIndex);
    } else {
      upvotes.add(Upvote(userId: userId, createdAt: DateTime.now()));
    }
  }

  @override
  Future<void> updateReportStatus({
    required String reportId,
    required ReportStatus status,
  }) async {
    updateStatusCallCount++;

    if (shouldThrowUpdateStatusError) {
      throw Exception('Failed to update report status');
    }

    lastUpdatedReportId = reportId;
    lastStatus = status;
  }

  @override
  Future<void> forwardReport({
    required String reportId,
    required String agencyId,
  }) async {
    forwardReportCallCount++;

    if (shouldThrowForwardError) {
      throw Exception('Failed to forward report');
    }

    lastForwardedReportId = reportId;
    lastAgencyId = agencyId;
  }

  @override
  Future<void> declineReport({
    required String reportId,
    required DeclineReason reason,
    String? feedback,
  }) async {
    declineReportCallCount++;

    if (shouldThrowDeclineError) {
      throw Exception('Failed to decline report');
    }

    lastDeclinedReportId = reportId;
    lastDeclineReason = reason;
    lastDeclineFeedback = feedback;
  }

  @override
  Future<void> deleteReport(String reportId) async {
    if (shouldThrowDeleteReportError) {
      throw Exception('Failed to delete report');
    }

    deletedReportId = reportId;
  }
}
