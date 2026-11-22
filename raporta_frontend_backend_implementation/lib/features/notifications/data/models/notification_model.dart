import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/app_notification.dart';

class NotificationModel extends AppNotification {
  const NotificationModel({
    required super.notificationId,
    required super.userId,
    required super.reportId,
    required super.message,
    required super.read,
    required super.createdAt,
    required super.updatedAt,
  });

  factory NotificationModel.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data();

    if (data == null) {
      throw FormatException(
        'Notification document ${document.id} has no data.',
      );
    }

    // firestore briefly reports a pending FieldValue.serverTimestamp()
    // write as null before the server resolves it. fall back instead of crashing
    final createdAt =
        (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();
    final updatedAt = (data['updatedAt'] as Timestamp?)?.toDate() ?? createdAt;

    return NotificationModel(
      notificationId: document.id,
      userId: data['userId'] as String,
      reportId: data['reportId'] as String,
      message: data['message'] as String,
      read: data['read'] as bool,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
