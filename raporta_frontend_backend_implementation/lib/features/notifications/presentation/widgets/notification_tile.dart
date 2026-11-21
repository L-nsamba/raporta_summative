import 'package:flutter/material.dart';

import '../../domain/entities/app_notification.dart';

class NotificationTile extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const NotificationTile({
    super.key,
    required this.notification,
    required this.onTap,
  });

  ({IconData icon, Color color}) get _iconData {
    final message = notification.message.toLowerCase();

    if (message.contains('upvote')) {
      return (icon: Icons.thumb_up, color: Colors.orange);
    }
    if (message.contains('submitted')) {
      return (icon: Icons.description_outlined, color: Colors.orange);
    }
    if (message.contains('forwarded')) {
      return (icon: Icons.forward_outlined, color: Colors.lightBlue);
    }
    if (message.contains('resolved')) {
      return (icon: Icons.check_circle, color: Colors.green);
    }
    if (message.contains('status')) {
      return (icon: Icons.sync, color: Colors.lightBlue);
    }
    return (icon: Icons.notifications, color: Colors.grey);
  }

  String _relativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) {
      return '${diff.inMinutes} minute${diff.inMinutes == 1 ? '' : 's'} ago';
    }
    if (diff.inHours < 24) {
      return '${diff.inHours} hour${diff.inHours == 1 ? '' : 's'} ago';
    }
    if (diff.inDays == 1) return 'Yesterday';
    if (diff.inDays < 7) return '${diff.inDays} days ago';
    return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
  }

  @override
  Widget build(BuildContext context) {
    final iconData = _iconData;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 10,
              child: notification.read
                  ? null
                  : Container(
                      margin: const EdgeInsets.only(top: 6),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
            ),

            CircleAvatar(
              backgroundColor: iconData.color,
              child: Icon(iconData.icon, color: Colors.white, size: 18),
            ),
            
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    notification.message,
                    style: TextStyle(
                      fontWeight:
                          notification.read ? FontWeight.normal : FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _relativeTime(notification.createdAt),
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}