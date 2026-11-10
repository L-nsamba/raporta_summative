import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

class WatchNotifications {
  final NotificationsRepository repository;

  WatchNotifications({required this.repository});

  Stream<List<AppNotification>> call(String userId) {
    return repository.watchNotifications(userId);
  }
}
