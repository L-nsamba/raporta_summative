import '../../domain/entities/app_notification.dart';
import '../../domain/repositories/notifications_repository.dart';
import '../datasources/notifications_remote_datasource.dart';

class NotificationsRepositoryImpl implements NotificationsRepository {
  final NotificationsRemoteDataSource remoteDataSource;

  NotificationsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<List<AppNotification>> getNotifications(String userId) {
    return remoteDataSource.getNotifications(userId);
  }

  @override
  Stream<List<AppNotification>> watchNotifications(String userId) {
    return remoteDataSource.watchNotifications(userId);
  }

  @override
  Future<void> markNotificationRead(String notificationId) {
    return remoteDataSource.markNotificationRead(notificationId);
  }
}
