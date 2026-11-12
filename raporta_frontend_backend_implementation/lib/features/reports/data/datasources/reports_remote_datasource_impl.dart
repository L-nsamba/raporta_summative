import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/decline_reason.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/data/datasources/reports_remote_datasource.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../models/report_model.dart';
import '../models/upvote_model.dart';

class ReportsRemoteDataSourceImpl implements ReportsRemoteDataSource {
  final FirebaseFirestore firestore;

  ReportsRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _reportsCollection =>
      firestore.collection(FirestoreCollections.reports);

  @override
  Future<String> createReport(ReportModel report) async {
    final document = _reportsCollection.doc();

    await document.set({
      ...report.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
      'deletedAt': null,
    });

    return document.id;
  }

  @override
  Future<List<ReportModel>> getReports() async {
    final snapshot = await _reportsCollection
        .where('deletedAt', isNull: true)
        .get();

    final reports = snapshot.docs
        .map((document) => ReportModel.fromFirestore(document))
        .toList();

    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return reports;
  }

  @override
  Future<ReportModel?> getReportById(String reportId) async {
    final document = await _reportsCollection.doc(reportId).get();

    if (!document.exists) {
      return null;
    }

    final report = ReportModel.fromFirestore(document);

    if (report.deletedAt != null) {
      return null;
    }

    return report;
  }

  @override
  Future<List<ReportModel>> getMyReports(String userId) async {
    final snapshot = await _reportsCollection
        .where('userId', isEqualTo: userId)
        .where('deletedAt', isNull: true)
        .get();

    final reports = snapshot.docs
        .map((document) => ReportModel.fromFirestore(document))
        .toList();

    reports.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return reports;
  }

  @override
  Future<void> deleteReport(String reportId) async {
    await _reportsCollection.doc(reportId).update({
      'deletedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<List<UpvoteModel>> getUpvotes(String reportId) async {
    final snapshot = await _reportsCollection
        .doc(reportId)
        .collection('upvotes')
        .get();

    return snapshot.docs
        .map((document) => UpvoteModel.fromFirestore(document))
        .toList();
  }

  @override
  Future<void> toggleUpvote({
    required String reportId,
    required String userId,
  }) async {
    final upvoteReference = _reportsCollection
        .doc(reportId)
        .collection('upvotes')
        .doc(userId);

    await firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(upvoteReference);

      if (snapshot.exists) {
        transaction.delete(upvoteReference);
      } else {
        transaction.set(upvoteReference, {
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
    });
  }

  @override
  Future<void> updateReportStatus({
    required String reportId,
    required ReportStatus status,
  }) async {
    await _reportsCollection.doc(reportId).update({
      'status': _statusToFirestore(status),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> forwardReport({
    required String reportId,
    required String agencyId,
  }) async {
    await _reportsCollection.doc(reportId).update({
      'status': 'forwarded',
      'agencyId': agencyId,
      'declineReason': null,
      'declineFeedback': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> declineReport({
    required String reportId,
    required DeclineReason reason,
    String? feedback,
  }) async {
    await _reportsCollection.doc(reportId).update({
      'status': 'declined',
      'declineReason': _declineReasonToFirestore(reason),
      'declineFeedback': feedback,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}

String _statusToFirestore(ReportStatus status) {
  switch (status) {
    case ReportStatus.pending:
      return 'pending';
    case ReportStatus.underReview:
      return 'under_review';
    case ReportStatus.forwarded:
      return 'forwarded';
    case ReportStatus.inProgress:
      return 'in_progress';
    case ReportStatus.resolved:
      return 'resolved';
    case ReportStatus.declined:
      return 'declined';
  }
}

String _declineReasonToFirestore(DeclineReason reason) {
  switch (reason) {
    case DeclineReason.duplicate:
      return 'duplicate';
    case DeclineReason.unrelated:
      return 'unrelated';
    case DeclineReason.alreadyResolved:
      return 'already_resolved';
    case DeclineReason.other:
      return 'other';
  }
}
