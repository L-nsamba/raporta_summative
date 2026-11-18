import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class PhotoPickerField extends StatelessWidget {
  final String? photoPath;
  final String? photoUrl;
  final ValueChanged<String> onPhotoSelected;
  final VoidCallback onPhotoRemoved;
  final bool enabled;

  const PhotoPickerField({
    super.key,
    required this.photoPath,
    required this.photoUrl,
    required this.onPhotoSelected,
    required this.onPhotoRemoved,
    this.enabled = true,
  });

  static const int _maxFileSize = 5 * 1024 * 1024;

  Future<void> _pickPhoto(BuildContext context) async {
    if (!enabled) return;

    try {
      final image = await ImagePicker().pickImage(
        source: ImageSource.gallery,
        maxWidth: 1600,
        maxHeight: 1600,
        imageQuality: 80,
      );

      if (image == null || !context.mounted) return;

      final size = await image.length();

      if (!context.mounted) return;

      if (size > _maxFileSize) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please select an image smaller than 5 MB.'),
          ),
        );
        return;
      }

      onPhotoSelected(image.path);
    } catch (_) {
      if (!context.mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Unable to select photo. Please try again.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoPath != null || photoUrl != null;
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Image attachment (Optional)', style: theme.textTheme.titleSmall),
        const SizedBox(height: 6),
        Text(
          'Attach a photo to help illustrate the issue. Maximum 5 MB.',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),

        if (!hasPhoto)
          InkWell(
            onTap: enabled ? () => _pickPhoto(context) : null,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              width: double.infinity,
              height: 160,
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outlineVariant),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.add_photo_alternate_outlined,
                    size: 40,
                    color: theme.colorScheme.primary,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Tap to select a photo',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 4),
                  Text('From your gallery', style: theme.textTheme.bodySmall),
                ],
              ),
            ),
          )
        else
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  height: 190,
                  width: double.infinity,
                  child: photoPath != null
                      ? Image.file(
                          File(photoPath!),
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              const Center(
                                child: Icon(
                                  Icons.broken_image_outlined,
                                  size: 40,
                                ),
                              ),
                        )
                      : Image.network(
                          photoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) => const Center(
                            child: Icon(Icons.broken_image_outlined, size: 40),
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  TextButton.icon(
                    onPressed: enabled ? () => _pickPhoto(context) : null,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Change'),
                  ),
                  const Spacer(),
                  TextButton.icon(
                    onPressed: enabled ? onPhotoRemoved : null,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Remove'),
                  ),
                ],
              ),
            ],
          ),
      ],
    );
  }
}
