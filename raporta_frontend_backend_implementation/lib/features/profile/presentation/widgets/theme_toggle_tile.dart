import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/preferences_cubit.dart';

class ThemeToggleTile extends StatelessWidget {
  const ThemeToggleTile({super.key});

  @override
  Widget build(BuildContext context) {
    final prefs = context.watch<PreferencesCubit>().state;

    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        backgroundColor: Colors.grey.shade100,
        child: const Icon(Icons.dark_mode_outlined, color: Colors.black87),
      ),
      title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
      subtitle: const Text('Change appearance of your app'),
      trailing: Switch(
        value: prefs.preferences.isDarkMode,
        onChanged: (value) => context.read<PreferencesCubit>().updateDarkMode(value),
      ),
    );
  }
}