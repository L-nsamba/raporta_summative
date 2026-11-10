import 'package:raporta_frontend_backend_implementation/features/notifications/domain/entities/app_notification.dart';

abstract class NotificationsRepository {
  Future<List<AppNotification>> getNotifications(String userId);

  Stream<List<AppNotification>> watchNotifications(String userId);

  Future<void> markNotificationRead(String notificationId);
}
