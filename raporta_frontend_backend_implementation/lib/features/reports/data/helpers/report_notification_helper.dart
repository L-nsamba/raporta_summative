import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/enums/report_status.dart';

class ReportNotificationHelper {
  const ReportNotificationHelper._();

  // Notification ID for a report status change.
  static String statusNotificationId({
    required String reportId,
    required ReportStatus status,
  }) {
    return '${reportId}_status_${status.toFirestore()}';
  }

  // Predefined messages for report status changes.
  static String statusMessage(ReportStatus status) {
    switch (status) {
      case ReportStatus.pending:
        return 'Your report has been submitted for review.';

      case ReportStatus.underReview:
        return 'Your report has been approved and is now under review.';

      case ReportStatus.forwarded:
        return 'Your report has been forwarded to the relevant agency.';

      case ReportStatus.inProgress:
        return 'Work on your reported issue is now in progress.';

      case ReportStatus.resolved:
        return 'Your reported issue has been resolved.';

      case ReportStatus.declined:
        return 'Your report has been declined. View the report for more details.';
    }
  }

  // Build a Firestore notification document.
  static Map<String, dynamic> buildNotification({
    required String userId,
    required String reportId,
    required String message,
  }) {
    return {
      'userId': userId,
      'reportId': reportId,
      'message': message,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  // Predefined message for new report submissions.
  static const String newReportMessage =
      'A new report has been submitted for review.';

  // Notification ID for a newly submitted report.
  static String newReportNotificationId({required String reportId}) {
    return '${reportId}_new_report';
  }

  // Message for report upvote notifications.
  static const String upvoteMessage = 'Someone has upvoted your report.';

  // Unique notification ID for each report and voter.
  static String upvoteNotificationId({
    required String reportId,
    required String voterId,
  }) {
    return '${reportId}_upvote_$voterId';
  }
}
