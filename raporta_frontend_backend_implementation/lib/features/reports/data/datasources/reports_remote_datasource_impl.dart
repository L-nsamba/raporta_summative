
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/data/datasources/reports_remote_datasource.dart';

import '../../../../core/constants/firestore_collections.dart';
import '../models/report_model.dart';
import '../models/upvote_model.dart';

class ReportsRemoteDataSourceImpl
    implements ReportsRemoteDataSource {
  final FirebaseFirestore firestore;

  ReportsRemoteDataSourceImpl({
    required this.firestore,
  });

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
  Future<void> updateReport(ReportModel report) async {
    await _reportsCollection.doc(report.reportId).update({
      ...report.toFirestore(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
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
}