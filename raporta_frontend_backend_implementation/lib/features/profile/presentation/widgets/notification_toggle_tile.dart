import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/preferences_cubit.dart';
import '../../../../core/theme/app_colors.dart';

class NotificationToggleTile extends StatelessWidget {
  const NotificationToggleTile({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesCubit>().state;
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        child: const Icon(
          Icons.notifications_outlined,
          color: AppColors.background,
        ),
      ),
      title: const Text(
        'Notifications',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: const Text('Notification preferences'),
      trailing: Switch(
        value: prefs.preferences.notificationsEnabled,
        onChanged: (value) =>
            context.read<PreferencesCubit>().updateNotificationsEnabled(value),
      ),
    );
  }
}
