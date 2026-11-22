import 'package:flutter/material.dart';

enum SnackbarType { success, error, info }

class AppSnackbar {
  AppSnackbar._();

  static void show(
    BuildContext context, {
    required String message,
    SnackbarType type = SnackbarType.info,
  }) {
    final theme = Theme.of(context);

    final (Color backgroundColor, IconData icon) = switch (type) {
      SnackbarType.success => (
        Colors.green.shade700,
        Icons.check_circle_outline,
      ),
      SnackbarType.error => (theme.colorScheme.error, Icons.error_outline),
      SnackbarType.info => (
        theme.colorScheme.inverseSurface,
        Icons.info_outline,
      ),
    };

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: backgroundColor,
          behavior: SnackBarBehavior.floating,
          content: Row(
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
  }
}
