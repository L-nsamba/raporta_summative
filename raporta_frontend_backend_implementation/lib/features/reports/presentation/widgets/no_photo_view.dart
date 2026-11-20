import 'package:flutter/material.dart';

class NoPhotoView extends StatelessWidget {
  const NoPhotoView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ColoredBox(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_outlined,
            size: 54,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 8),
          Text('No photo attached', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}
