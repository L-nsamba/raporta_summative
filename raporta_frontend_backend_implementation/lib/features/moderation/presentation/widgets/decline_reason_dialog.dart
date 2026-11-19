import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/enums/decline_reason.dart';
import '../../../../core/widgets/app_snackbar.dart';

import '../cubit/moderation_cubit.dart';
import '../cubit/moderation_state.dart';

class DeclineReasonDialog extends StatefulWidget {
  final String reportId;
  final VoidCallback onDeclined;

  const DeclineReasonDialog({
    super.key,
    required this.reportId,
    required this.onDeclined,
  });

  @override
  State<DeclineReasonDialog> createState() => _DeclineReasonDialogState();
}

class _DeclineReasonDialogState extends State<DeclineReasonDialog> {
  DeclineReason? _selectedReason;

  final TextEditingController _feedbackController = TextEditingController();

  @override
  void dispose() {
    _feedbackController.dispose();
    super.dispose();
  }

  String _reasonLabel(DeclineReason reason) {
    return switch (reason) {
      DeclineReason.duplicate => 'Duplicate Report',
      DeclineReason.unrelated => 'Unrelated Issue',
      DeclineReason.alreadyResolved => 'Already Resolved',
      DeclineReason.other => 'Other',
    };
  }

  void _submitDecline(BuildContext context) {
    final reason = _selectedReason;

    // A reason must be selected.
    if (reason == null) return;

    final feedback = _feedbackController.text.trim();

    context.read<ModerationCubit>().decline(
      reportId: widget.reportId,
      reason: reason,
      feedback: feedback.isEmpty ? null : feedback,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return BlocConsumer<ModerationCubit, ModerationState>(
      listenWhen: (previous, current) => previous.status != current.status,

      listener: (context, state) {
        if (state.status == ModerationStatus.success) {
          Navigator.of(context).pop();

          // Ask the parent to refresh the pending queue.
          widget.onDeclined();
        }

        if (state.status == ModerationStatus.failure) {
          AppSnackbar.show(
            context,
            message:
                state.errorMessage ??
                'Unable to decline report. Please try again.',
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
                Icon(Icons.cancel_outlined, color: Colors.red),
                SizedBox(width: 10),
                Expanded(child: Text('Decline Report')),
              ],
            ),

            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Please select a reason for declining '
                    'this report.',
                  ),

                  const SizedBox(height: 20),

                  Text('Reason', style: theme.textTheme.titleSmall),

                  const SizedBox(height: 8),

                  // Select one of the existing enum values.
                  DropdownButtonFormField<DeclineReason>(
                    isExpanded: true,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Select a reason',
                    ),

                    items: DeclineReason.values.map((reason) {
                      return DropdownMenuItem<DeclineReason>(
                        value: reason,
                        child: Text(_reasonLabel(reason)),
                      );
                    }).toList(),

                    onChanged: isSubmitting
                        ? null
                        : (reason) {
                            setState(() {
                              _selectedReason = reason;
                            });
                          },
                  ),

                  const SizedBox(height: 20),

                  Text(
                    'Additional feedback (optional)',
                    style: theme.textTheme.titleSmall,
                  ),

                  const SizedBox(height: 8),

                  TextField(
                    controller: _feedbackController,
                    enabled: !isSubmitting,
                    maxLines: 3,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      hintText: 'Provide additional information...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),

            actions: [
              TextButton(
                onPressed: isSubmitting
                    ? null
                    : () => Navigator.of(context).pop(),
                child: const Text('Cancel'),
              ),

              FilledButton.icon(
                onPressed: isSubmitting || _selectedReason == null
                    ? null
                    : () => _submitDecline(context),

                icon: isSubmitting
                    ? const SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.close),

                label: Text(isSubmitting ? 'Declining...' : 'Decline Report'),

                style: FilledButton.styleFrom(
                  backgroundColor: theme.colorScheme.error,
                  foregroundColor: theme.colorScheme.onError,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
