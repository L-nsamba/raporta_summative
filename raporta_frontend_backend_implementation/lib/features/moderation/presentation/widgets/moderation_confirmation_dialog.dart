import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/report_status.dart';
import '../../../../core/widgets/app_snackbar.dart';

import '../cubit/moderation_cubit.dart';
import '../cubit/moderation_state.dart';

class ModerationConfirmationDialog extends StatelessWidget {
  final String reportId;
  final ReportStatus targetStatus;
  final String title;
  final String message;
  final String confirmLabel;
  final VoidCallback onSuccess;

  const ModerationConfirmationDialog({
    super.key,
    required this.reportId,
    required this.targetStatus,
    required this.title,
    required this.message,
    required this.confirmLabel,
    required this.onSuccess,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ModerationCubit, ModerationState>(
      listenWhen: (previous, current) => previous.status != current.status,

      listener: (context, state) {
        if (state.status == ModerationStatus.success) {
          Navigator.of(context).pop();
          onSuccess();
        }

        if (state.status == ModerationStatus.failure) {
          AppSnackbar.show(
            context,
            message:
                state.errorMessage ??
                'Unable to update report. Please try again.',
            type: SnackbarType.error,
          );
        }
      },

      builder: (context, state) {
        final isSubmitting = state.status == ModerationStatus.submitting;

        return PopScope(
          canPop: !isSubmitting,
          child: AlertDialog(
            title: Text(title),

            content: Text(message),

            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),

              FilledButton(
                onPressed: isSubmitting
                    ? null
                    : () {
                        context.read<ModerationCubit>().updateStatus(
                          reportId: reportId,
                          status: targetStatus,
                        );
                      },

                child: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(confirmLabel),
              ),
            ],
          ),
        );
      },
    );
  }
}
