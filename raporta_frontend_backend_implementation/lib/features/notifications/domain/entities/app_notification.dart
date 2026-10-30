class AppNotification {
  final String notificationId;
  final String userId;
  final String reportId;
  final String message;
  final bool read;
  final DateTime createdAt;
  final DateTime updatedAt;

  const AppNotification({
    required this.notificationId,
    required this.userId,
    required this.reportId,
    required this.message,
    required this.read,
    required this.createdAt,
    required this.updatedAt,
  });
}
