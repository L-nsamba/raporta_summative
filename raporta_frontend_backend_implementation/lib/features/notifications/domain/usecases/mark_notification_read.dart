import '../repositories/notifications_repository.dart';

class MarkNotificationRead {
  final NotificationsRepository repository;

  MarkNotificationRead({required this.repository});

  Future<void> call(String notificationId) {
    return repository.markNotificationRead(notificationId);
  }
}
