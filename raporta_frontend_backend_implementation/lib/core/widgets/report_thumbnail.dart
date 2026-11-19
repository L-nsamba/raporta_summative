import 'package:flutter/material.dart';

class ReportThumbnail extends StatelessWidget {
  final String? photoUrl;
  final double size;

  const ReportThumbnail({super.key, this.photoUrl, this.size = 96});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: size,
        height: size,
        child: hasPhoto
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const _NoPhotoPlaceholder();
                },
              )
            : const _NoPhotoPlaceholder(),
      ),
    );
  }
}

class _NoPhotoPlaceholder extends StatelessWidget {
  const _NoPhotoPlaceholder();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerHighest,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_outlined,
            size: 30,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 4),
          Text('No photo', style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
