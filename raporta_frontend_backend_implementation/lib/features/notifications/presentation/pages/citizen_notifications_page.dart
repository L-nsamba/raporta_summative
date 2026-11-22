import 'package:flutter/material.dart';

import '../widgets/notifications_view.dart';

class CitizenNotificationsPage extends StatelessWidget {
  const CitizenNotificationsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const NotificationsView(title: 'Notifications', isOfficial: false);
  }
}
