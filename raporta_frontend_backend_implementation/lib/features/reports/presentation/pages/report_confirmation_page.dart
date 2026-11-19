import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/enums/report_category.dart';
import '../../../../core/widgets/app_button.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/report_form_cubit.dart';
import '../cubit/report_form_state.dart';

class ReportConfirmationPage extends StatelessWidget {
  const ReportConfirmationPage({super.key});

  String _categoryLabel(ReportCategory category) {
    final name = category.name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    return name[0].toUpperCase() + name.substring(1);
  }

  Future<void> _submitReport(BuildContext context) async {
    final user = context.read<AuthBloc>().state.user;

    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please sign in again to submit your report.'),
        ),
      );
      return;
    }

    await context.read<ReportFormCubit>().submitReport(
      userId: user.userId,
      areaId: user.areaId,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportFormCubit, ReportFormState>(
      builder: (context, state) {
        if (state.submissionStatus == FormSubmissionStatus.success) {
          return _ReportSuccessView(reportId: state.createdReportId);
        }

        final theme = Theme.of(context);
        final isUploading =
            state.submissionStatus == FormSubmissionStatus.uploadingPhoto;

        final isSubmitting =
            state.submissionStatus == FormSubmissionStatus.submitting;

        return ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text(
              'Review Your Report',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Please check the details before submitting.',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),

            const SizedBox(height: 24),

            _ReviewSection(
              title: 'Issue Details',
              icon: Icons.description_outlined,
              children: [
                _ReviewField(
                  label: 'Category',
                  value: state.category == null
                      ? 'Not selected'
                      : _categoryLabel(state.category!),
                ),
                const SizedBox(height: 12),
                _ReviewField(
                  label: 'Description',
                  value: state.description.trim(),
                ),
              ],
            ),

            const SizedBox(height: 16),

            _ReviewSection(
              title: 'Location',
              icon: Icons.location_on_outlined,
              children: [
                _ReviewField(
                  label: 'Location description',
                  value: state.locationDescription.trim(),
                ),
                const SizedBox(height: 12),
                _ReviewField(
                  label: 'Coordinates',
                  value: state.lat != null && state.lng != null
                      ? '${state.lat!.toStringAsFixed(6)}, '
                            '${state.lng!.toStringAsFixed(6)}'
                      : 'Not selected',
                ),
              ],
            ),

            const SizedBox(height: 16),

            _ReviewSection(
              title: 'Photo Attachment',
              icon: Icons.image_outlined,
              children: [
                if (!state.hasPhoto)
                  const Text('No photo attached (optional).')
                else
                  _PhotoReview(
                    photoPath: state.photoPath,
                    photoUrl: state.photoUrl,
                  ),
              ],
            ),

            const SizedBox(height: 20),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.info_outline, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Text(
                        'Your report will be submitted for official '
                        'review. It will become publicly visible '
                        'once approved.',
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (state.errorMessage != null) ...[
              const SizedBox(height: 16),
              Text(
                state.errorMessage!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],

            const SizedBox(height: 24),

            if (state.isBusy) ...[
              const Center(child: CircularProgressIndicator()),
              const SizedBox(height: 12),
              Text(
                isUploading
                    ? 'Uploading your photo...'
                    : 'Submitting your report...',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
            ],

            AppButton(
              label: isSubmitting
                  ? 'Submitting...'
                  : isUploading
                  ? 'Uploading Photo...'
                  : state.submissionStatus == FormSubmissionStatus.failure
                  ? 'Try Again'
                  : 'Submit Report',
              isLoading: state.isBusy,
              onPressed: state.isBusy ? null : () => _submitReport(context),
            ),

            const SizedBox(height: 12),

            TextButton(
              onPressed: state.isBusy
                  ? null
                  : () => context.read<ReportFormCubit>().previousStep(),
              child: const Text('Back to Location'),
            ),

            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<Widget> children;

  const _ReviewSection({
    required this.title,
    required this.icon,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: theme.colorScheme.primary),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const Divider(height: 24),
            ...children,
          ],
        ),
      ),
    );
  }
}

class _ReviewField extends StatelessWidget {
  final String label;
  final String value;

  const _ReviewField({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 5),
        Text(value, style: theme.textTheme.bodyMedium),
      ],
    );
  }
}

class _PhotoReview extends StatelessWidget {
  final String? photoPath;
  final String? photoUrl;

  const _PhotoReview({required this.photoPath, required this.photoUrl});

  @override
  Widget build(BuildContext context) {
    final Widget photo;

    if (photoPath != null) {
      photo = Image.file(
        File(photoPath!),
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.broken_image_outlined)),
      );
    } else if (photoUrl != null) {
      photo = Image.network(
        photoUrl!,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) =>
            const Center(child: Icon(Icons.broken_image_outlined)),
      );
    } else {
      photo = const Center(child: Icon(Icons.image_not_supported));
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: SizedBox(height: 180, width: double.infinity, child: photo),
    );
  }
}

class _ReportSuccessView extends StatelessWidget {
  final String? reportId;

  const _ReportSuccessView({required this.reportId});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircleAvatar(
            radius: 65,
            backgroundColor: theme.colorScheme.primary,
            child: Icon(
              Icons.check,
              size: 80,
              color: theme.colorScheme.onPrimary,
            ),
          ),

          const SizedBox(height: 28),

          Text(
            'Congratulations!',
            style: theme.textTheme.headlineMedium?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 12),

          Text(
            'Your report was successfully submitted.',
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium,
          ),

          const SizedBox(height: 12),

          Text(
            'It is now awaiting official review.',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),

          const SizedBox(height: 42),

          AppButton(
            label: 'Back To Menu',
            onPressed: () => context.go(RouteNames.citizenDashboard),
          ),

          const SizedBox(height: 12),

          TextButton(
            onPressed: () => context.go(RouteNames.myReports),
            child: const Text('View My Reports'),
          ),
        ],
      ),
    );
  }
}
