import '../../domain/entities/app_notification.dart';

abstract class NotificationsEvent {
  const NotificationsEvent();
}

class NotificationsStarted extends NotificationsEvent {
  final String userId;

  const NotificationsStarted(this.userId);
}

class NotificationsUpdated extends NotificationsEvent {
  final List<AppNotification> notifications;

  const NotificationsUpdated(this.notifications);
}

class NotificationMarkedRead extends NotificationsEvent {
  final String notificationId;

  const NotificationMarkedRead(this.notificationId);
}

class NotificationsStopped extends NotificationsEvent {
  const NotificationsStopped();
}

