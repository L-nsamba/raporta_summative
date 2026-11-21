import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/dependency_injection/injection_container.dart';
import '../../../../core/widgets/app_snackbar.dart';

import '../../domain/entities/agency.dart';
import '../cubit/agencies_cubit.dart';
import '../cubit/agencies_state.dart';
import '../cubit/moderation_cubit.dart';
import '../cubit/moderation_state.dart';

class ForwardAgencyDialog extends StatelessWidget {
  final String reportId;
  final VoidCallback onForwarded;

  const ForwardAgencyDialog({
    super.key,
    required this.reportId,
    required this.onForwarded,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider<AgenciesCubit>(
      create: (_) => sl<AgenciesCubit>()..loadAgencies(),
      child: _ForwardAgencyDialogContent(
        reportId: reportId,
        onForwarded: onForwarded,
      ),
    );
  }
}

class _ForwardAgencyDialogContent extends StatefulWidget {
  final String reportId;
  final VoidCallback onForwarded;

  const _ForwardAgencyDialogContent({
    required this.reportId,
    required this.onForwarded,
  });

  @override
  State<_ForwardAgencyDialogContent> createState() =>
      _ForwardAgencyDialogContentState();
}

class _ForwardAgencyDialogContentState
    extends State<_ForwardAgencyDialogContent> {
  Agency? _selectedAgency;

  void _submitForward() {
    final agency = _selectedAgency;
    final moderationCubit = context.read<ModerationCubit>();

    if (agency == null ||
        moderationCubit.state.status == ModerationStatus.submitting) {
      return;
    }

    moderationCubit.forward(
      reportId: widget.reportId,
      agencyId: agency.agencyId,
    );
  }

  Widget _buildAgencySelection(bool isSubmitting) {
    return BlocBuilder<AgenciesCubit, AgenciesState>(
      builder: (context, state) {
        switch (state.status) {
          case AgenciesStatus.initial:
          case AgenciesStatus.loading:
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Center(child: CircularProgressIndicator()),
            );

          case AgenciesStatus.empty:
            return const Text(
              'No agencies are currently available '
              'for forwarding this report.',
            );

          case AgenciesStatus.failure:
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(state.errorMessage ?? 'Unable to load agencies.'),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: isSubmitting
                      ? null
                      : () {
                          context.read<AgenciesCubit>().loadAgencies();
                        },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ],
            );

          case AgenciesStatus.loaded:
            return DropdownButtonFormField<Agency>(
              key: ValueKey(_selectedAgency?.agencyId),
              initialValue: _selectedAgency,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Agency',
                hintText: 'Select an agency',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.business_outlined),
              ),
              items: state.agencies.map((agency) {
                return DropdownMenuItem<Agency>(
                  value: agency,
                  child: Text(
                    '${agency.name} (${agency.category})',
                    overflow: TextOverflow.ellipsis,
                  ),
                );
              }).toList(),
              onChanged: isSubmitting
                  ? null
                  : (agency) {
                      setState(() {
                        _selectedAgency = agency;
                      });
                    },
            );
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<ModerationCubit, ModerationState>(
      listenWhen: (previous, current) => previous.status != current.status,

      listener: (context, state) {
        if (state.status == ModerationStatus.success) {
          Navigator.of(context).pop();
          widget.onForwarded();
        }

        if (state.status == ModerationStatus.failure) {
          AppSnackbar.show(
            context,
            message:
                state.errorMessage ??
                'Unable to forward report. Please try again.',
            type: SnackbarType.error,
          );
        }
      },

      builder: (context, moderationState) {
        final isSubmitting =
            moderationState.status == ModerationStatus.submitting;

        return PopScope(
          canPop: !isSubmitting,

          child: AlertDialog(
            title: const Text('Forward to Agency'),

            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select the agency responsible '
                    'for handling this report.',
                  ),

                  const SizedBox(height: 20),

                  _buildAgencySelection(isSubmitting),
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

              BlocBuilder<AgenciesCubit, AgenciesState>(
                builder: (context, agenciesState) {
                  final canForward =
                      agenciesState.status == AgenciesStatus.loaded &&
                      _selectedAgency != null &&
                      !isSubmitting;

                  return FilledButton.icon(
                    onPressed: canForward ? _submitForward : null,

                    icon: isSubmitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_outlined),

                    label: Text(
                      isSubmitting ? 'Forwarding...' : 'Forward Report',
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
