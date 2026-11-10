import '../../domain/entities/app_notification.dart';

enum NotificationsStatus { initial, loading, loaded, failure }

class NotificationsState {
  final NotificationsStatus status;
  final List<AppNotification> notifications;
  final String? errorMessage;

  const NotificationsState({
    this.status = NotificationsStatus.initial,
    this.notifications = const [],
    this.errorMessage,
  });

  int get unreadCount =>
      notifications.where((notification) => !notification.read).length;

  NotificationsState copyWith({
    NotificationsStatus? status,
    List<AppNotification>? notifications,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notifications: notifications ?? this.notifications,
      errorMessage: errorMessage,
    );
  }
}
