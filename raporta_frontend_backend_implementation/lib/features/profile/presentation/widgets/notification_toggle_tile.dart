import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/preferences_cubit.dart';

class NotificationToggleTile extends StatelessWidget {
  const NotificationToggleTile({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesCubit>().state;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade100,
        child: const Icon(Icons.notifications_outlined, color: Colors.black87),
      ),
      title: const Text('Notifications', style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: const Text('Notification preferences'),
      trailing: Switch(
        value: prefs.preferences.notificationsEnabled,
        onChanged: (value) =>
            context.read<PreferencesCubit>().updateNotificationsEnabled(value),
      ),
    );
  }
}