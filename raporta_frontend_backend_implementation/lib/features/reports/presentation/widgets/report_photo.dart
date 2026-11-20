import 'package:flutter/material.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/widgets/no_photo_view.dart';

class ReportPhoto extends StatelessWidget {
  final String? photoUrl;

  const ReportPhoto({super.key, this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = photoUrl != null && photoUrl!.trim().isNotEmpty;

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        width: double.infinity,
        height: 230,
        child: hasPhoto
            ? Image.network(
                photoUrl!,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;

                  return const Center(child: CircularProgressIndicator());
                },
                errorBuilder: (context, error, stackTrace) {
                  return const NoPhotoView();
                },
              )
            : const NoPhotoView(),
      ),
    );
  }
}
