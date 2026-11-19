import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/report_status.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../cubit/moderation_cubit.dart';
import '../cubit/moderation_state.dart';

class ApprovalConfirmationDialog extends StatelessWidget {
  final String reportId;
  final VoidCallback onApproved;

  const ApprovalConfirmationDialog({
    super.key,
    required this.reportId,
    required this.onApproved,
  });

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ModerationCubit, ModerationState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        if (state.status == ModerationStatus.success) {
          // Close the dialog only after successful approval.
          Navigator.of(context).pop();

          // Notify the parent page so it can refresh the queue.
          onApproved();
        }

        if (state.status == ModerationStatus.failure) {
          // Keep the dialog open and display the error.
          AppSnackbar.show(
            context,
            message:
                state.errorMessage ??
                'Unable to approve report. Please try again.',
            type: SnackbarType.error,
          );
        }
      },
      builder: (context, state) {
        final isSubmitting = state.status == ModerationStatus.submitting;

        return PopScope(
          canPop: !isSubmitting,
          child: AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.check_circle_outline, color: Colors.green),
                SizedBox(width: 10),
                Expanded(child: Text('Approve Report?')),
              ],
            ),

            content: const Text(
              'Are you sure you want to approve this report? '
              'It will become publicly visible and its status '
              'will change to Under Review.',
            ),

            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),

              FilledButton.icon(
                onPressed: isSubmitting
                    ? null
                    : () {
                        context.read<ModerationCubit>().updateStatus(
                          reportId: reportId,
                          status: ReportStatus.underReview,
                        );
                      },
                icon: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.check),
                label: Text(isSubmitting ? 'Approving...' : 'Approve'),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.green.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
