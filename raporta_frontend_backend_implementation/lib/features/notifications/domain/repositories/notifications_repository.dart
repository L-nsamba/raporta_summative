import 'package:raporta_frontend_backend_implementation/features/notifications/domain/entities/app_notification.dart';

abstract class NotificationsRepository {
  // Retrieve notifications for a user
  Future<List<AppNotification>> getNotifications(String userId);

  // Listen for real-time notification updates
  Stream<List<AppNotification>> watchNotifications(String userId);

  // Create a notification
  Future<void> createNotification(AppNotification notification);

  // Mark a notification as read
  Future<void> markNotificationRead(String notificationId);

  // Delete a notification
  Future<void> deleteNotification(String notificationId);
}
