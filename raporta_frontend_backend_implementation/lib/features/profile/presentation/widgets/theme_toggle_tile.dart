import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/preferences_cubit.dart';
import '../../../../core/theme/app_colors.dart';

class ThemeToggleTile extends StatelessWidget {
  const ThemeToggleTile({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesCubit>().state;
    final theme = Theme.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: theme.colorScheme.surfaceContainerHigh,
        child: const Icon(
          Icons.dark_mode_outlined,
          color: AppColors.background,
        ),
      ),
      title: const Text(
        'Dark Mode',
        style: TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: const Text('Change appearance of your app'),
      trailing: Switch(
        value: prefs.preferences.isDarkMode,
        onChanged: (value) =>
            context.read<PreferencesCubit>().updateDarkMode(value),
      ),
    );
  }
}
