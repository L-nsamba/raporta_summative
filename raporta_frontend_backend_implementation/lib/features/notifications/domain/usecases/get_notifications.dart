import '../entities/app_notification.dart';
import '../repositories/notifications_repository.dart';

class GetNotifications {
  final NotificationsRepository repository;

  GetNotifications({required this.repository});

  Future<List<AppNotification>> call(String userId) {
    return repository.getNotifications(userId);
  }
}
