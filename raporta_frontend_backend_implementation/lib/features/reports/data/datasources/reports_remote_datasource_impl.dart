import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/decline_reason.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/data/datasources/reports_remote_datasource.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/data/helpers/report_notification_helper.dart';

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
    // Generate the report ID before saving it.
    final document = _reportsCollection.doc();

    // Retrieve the designated official.
    final configSnapshot = await firestore
        .collection(FirestoreCollections.appConfig)
        .doc('moderation')
        .get();

    final officialId = configSnapshot.data()?['officialId'];

    if (officialId is! String || officialId.trim().isEmpty) {
      throw StateError('No moderation official has been configured.');
    }

    // Generate the new report notification ID.
    final notificationId = ReportNotificationHelper.newReportNotificationId(
      reportId: document.id,
    );

    final notificationRef = firestore
        .collection(FirestoreCollections.notifications)
        .doc(notificationId);

    // Prepare the notification.
    final notificationData = ReportNotificationHelper.buildNotification(
      userId: officialId,
      reportId: document.id,
      message: ReportNotificationHelper.newReportMessage,
    );

    final batch = firestore.batch();

    // Create the report.
    batch.set(document, {
      ...report.toFirestore(),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'status': 'pending',
      'deletedAt': null,
    });

    // Create the official's notification.
    batch.set(notificationRef, notificationData);

    // Save both documents together.
    await batch.commit();

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
  Future<List<ReportModel>> getPublicReports() async {
    final snapshot = await _reportsCollection
        .where('deletedAt', isNull: true)
        .where(
          'status',
          whereIn: ReportStatus.values
              .where((status) => status.isPublic)
              .map((status) => status.toFirestore())
              .toList(),
        )
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
    final reportRef = _reportsCollection.doc(reportId);

    final upvoteRef = reportRef
        .collection(FirestoreCollections.upvotes)
        .doc(userId);

    final markerRef = reportRef
        .collection(FirestoreCollections.upvoteNotificationMarkers)
        .doc(userId);

    await firestore.runTransaction((transaction) async {
      // Check whether the user has already upvoted.
      final upvoteSnapshot = await transaction.get(upvoteRef);

      // If the upvote exists, remove it.
      if (upvoteSnapshot.exists) {
        transaction.delete(upvoteRef);
        return;
      }

      // Retrieve the report to identify its owner.
      final reportSnapshot = await transaction.get(reportRef);

      final reportData = reportSnapshot.data();

      if (!reportSnapshot.exists || reportData == null) {
        throw StateError('Report $reportId does not exist.');
      }

      final ownerId = reportData['userId'] as String;

      // Users can upvote their own reports without
      // generating a notification.
      if (ownerId == userId) {
        transaction.set(upvoteRef, {
          'userId': userId,
          'createdAt': FieldValue.serverTimestamp(),
        });

        return;
      }

      // Check whether this user has previously generated
      // an upvote notification for this report.
      final markerSnapshot = await transaction.get(markerRef);

      // Create the upvote.
      transaction.set(upvoteRef, {
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // If already notified, no additional notification
      // or marker is needed.
      if (markerSnapshot.exists) {
        return;
      }

      // Generate the notification ID.
      final notificationId = ReportNotificationHelper.upvoteNotificationId(
        reportId: reportId,
        voterId: userId,
      );

      final notificationRef = firestore
          .collection(FirestoreCollections.notifications)
          .doc(notificationId);

      final notificationData = ReportNotificationHelper.buildNotification(
        userId: ownerId,
        reportId: reportId,
        message: ReportNotificationHelper.upvoteMessage,
      );

      // Record that this voter has notified the owner.
      transaction.set(markerRef, {
        'userId': userId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      // Create the report owner's notification.
      transaction.set(notificationRef, notificationData);
    });
  }

  @override
  Future<void> updateReportStatus({
    required String reportId,
    required ReportStatus status,
  }) async {
    await _updateReportWithNotification(
      reportId: reportId,
      status: status,
      updates: {},
    );
  }

  Future<void> _updateReportWithNotification({
    required String reportId,
    required ReportStatus status,
    required Map<String, dynamic> updates,
  }) async {
    final reportRef = _reportsCollection.doc(reportId);

    // Retrieve the report to identify its owner.
    final reportSnapshot = await reportRef.get();

    final reportData = reportSnapshot.data();

    if (!reportSnapshot.exists || reportData == null) {
      throw StateError('Report $reportId does not exist.');
    }

    final ownerId = reportData['userId'] as String;

    // Generate a predictable notification ID.
    final notificationId = ReportNotificationHelper.statusNotificationId(
      reportId: reportId,
      status: status,
    );

    final notificationRef = firestore
        .collection('notifications')
        .doc(notificationId);

    final notificationData = ReportNotificationHelper.buildNotification(
      userId: ownerId,
      reportId: reportId,
      message: ReportNotificationHelper.statusMessage(status),
    );

    final batch = firestore.batch();

    // Update the report.
    batch.update(reportRef, {
      ...updates,
      'status': _statusToFirestore(status),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    // Create the corresponding notification.
    batch.set(notificationRef, notificationData);

    // Commit both operations together.
    await batch.commit();
  }

  @override
  Future<void> forwardReport({
    required String reportId,
    required String agencyId,
  }) async {
    await _updateReportWithNotification(
      reportId: reportId,
      status: ReportStatus.forwarded,
      updates: {
        'agencyId': agencyId,
        'declineReason': null,
        'declineFeedback': null,
      },
    );
  }

  @override
  Future<void> declineReport({
    required String reportId,
    required DeclineReason reason,
    String? feedback,
  }) async {
    await _updateReportWithNotification(
      reportId: reportId,
      status: ReportStatus.declined,
      updates: {
        'declineReason': _declineReasonToFirestore(reason),
        'declineFeedback': feedback,
      },
    );
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
