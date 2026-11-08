import 'package:raporta_frontend_backend_implementation/core/enums/decline_reason.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/upvotes.dart';

import '../../domain/entities/report.dart';
import '../../domain/repositories/reports_repository.dart';
import '../models/report_model.dart';

class ReportsRepositoryImpl implements ReportsRepository {
  final ReportsRemoteDataSource remoteDataSource;

  ReportsRepositoryImpl({required this.remoteDataSource});

  ReportModel _toModel(Report report) {
    return ReportModel(
      reportId: report.reportId,
      userId: report.userId,
      areaId: report.areaId,
      category: report.category,
      description: report.description,
      lat: report.lat,
      lng: report.lng,
      locationDescription: report.locationDescription,
      photoUrl: report.photoUrl,
      status: report.status,
      declineReason: report.declineReason,
      declineFeedback: report.declineFeedback,
      agencyId: report.agencyId,
      createdAt: report.createdAt,
      updatedAt: report.updatedAt,
      deletedAt: report.deletedAt,
    );
  }

  @override
  Future<String> createReport(Report report) {
    return remoteDataSource.createReport(_toModel(report));
  }

  @override
  Future<List<Report>> getReports() async {
    return remoteDataSource.getReports();
  }

  @override
  Future<Report?> getReportById(String reportId) async {
    return remoteDataSource.getReportById(reportId);
  }

  @override
  Future<List<Report>> getMyReports(String userId) async {
    return remoteDataSource.getMyReports(userId);
  }

  @override
  Future<void> updateReportStatus({
    required String reportId,
    required ReportStatus status,
  }) {
    return remoteDataSource.updateReportStatus(
      reportId: reportId,
      status: status,
    );
  }

  @override
  Future<void> forwardReport({
    required String reportId,
    required String agencyId,
  }) {
    return remoteDataSource.forwardReport(
      reportId: reportId,
      agencyId: agencyId,
    );
  }

  @override
  Future<void> declineReport({
    required String reportId,
    required DeclineReason reason,
    String? feedback,
  }) {
    return remoteDataSource.declineReport(
      reportId: reportId,
      reason: reason,
      feedback: feedback,
    );
  }

  @override
  Future<void> deleteReport(String reportId) {
    return remoteDataSource.deleteReport(reportId);
  }

  @override
  Future<List<Upvote>> getUpvotes(String reportId) async {
    return remoteDataSource.getUpvotes(reportId);
  }

  @override
  Future<void> toggleUpvote({
    required String reportId,
    required String userId,
  }) {
    return remoteDataSource.toggleUpvote(reportId: reportId, userId: userId);
  }
}
