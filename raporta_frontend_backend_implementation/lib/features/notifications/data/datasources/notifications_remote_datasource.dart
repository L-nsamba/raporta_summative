import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

abstract class NotificationsRemoteDataSource {
  Future<List<NotificationModel>> getNotifications(String userId);

  Stream<List<NotificationModel>> watchNotifications(String userId);

  Future<void> markNotificationRead(String notificationId);
}

class NotificationsRemoteDataSourceImpl
    implements NotificationsRemoteDataSource {
  final FirebaseFirestore firestore;

  NotificationsRemoteDataSourceImpl({required this.firestore});

  CollectionReference<Map<String, dynamic>> get _notificationsCollection =>
      firestore.collection('notifications');

  @override
  Future<List<NotificationModel>> getNotifications(String userId) async {
    final snapshot = await _notificationsCollection
        .where('userId', isEqualTo: userId)
        .get();

    final notifications = snapshot.docs
        .map(NotificationModel.fromFirestore)
        .toList();

    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return notifications;
  }

  @override
  Stream<List<NotificationModel>> watchNotifications(String userId) {
    return _notificationsCollection
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs
              .map(NotificationModel.fromFirestore)
              .toList();

          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          return notifications;
        });
  }

  @override
  Future<void> markNotificationRead(String notificationId) async {
    await _notificationsCollection.doc(notificationId).update({
      'read': true,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }
}
