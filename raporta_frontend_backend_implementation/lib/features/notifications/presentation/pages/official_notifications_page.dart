import 'package:flutter/material.dart';

import '../widgets/notifications_view.dart';

class OfficialNotificationsPage extends StatelessWidget {
  const OfficialNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationsView(title: 'Notifications', isOfficial: true);
  }
}