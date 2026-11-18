import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:raporta_frontend_backend_implementation/app/dependency_injection/injection_container.dart';
import 'package:raporta_frontend_backend_implementation/app/router/route_names.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/report_form_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/report_form_state.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/pages/report_details_step_page.dart';

class CreateReportPage extends StatelessWidget {
  const CreateReportPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => sl<ReportFormCubit>(),
      child: const _ReportSubmissionView(),
    );
  }
}

class _ReportSubmissionView extends StatelessWidget {
  const _ReportSubmissionView();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ReportFormCubit, ReportFormState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Report an Issue'),
            leading: IconButton(
              icon: Icon(
                state.currentStep == 0 ? Icons.close : Icons.arrow_back,
              ),
              onPressed: state.isBusy
                  ? null
                  : () {
                      if (state.currentStep > 0 &&
                          state.submissionStatus !=
                              FormSubmissionStatus.success) {
                        context.read<ReportFormCubit>().previousStep();
                      } else {
                        context.go(RouteNames.citizenDashboard);
                      }
                    },
            ),
          ),

          body: Column(
            children: [
              _StepProgressIndicator(currentStep: state.currentStep),
              Expanded(
                child: switch (state.currentStep) {
                  0 => const ReportDetailsStepPage(),

                  // Our location step will come here next
                  1 => Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text('Location step coming next'),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            context.read<ReportFormCubit>().previousStep();
                          },
                          child: const Text('Back'),
                        ),
                      ],
                    ),
                  ),

                  // Review and submission after location step
                  _ => const Center(child: Text('Review step coming next')),
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _StepProgressIndicator extends StatelessWidget {
  final int currentStep;

  const _StepProgressIndicator({required this.currentStep});

  @override
  Widget build(BuildContext context) {
    const labels = ['Details', 'Location', 'Review'];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),

      child: Row(
        children: List.generate(labels.length, (index) {
          final isCurrent = index == currentStep;
          final isCompleted = index < currentStep;

          return Expanded(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 14,
                  backgroundColor: isCurrent || isCompleted
                      ? Theme.of(context).colorScheme.primary
                      : Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: isCompleted
                      ? const Icon(Icons.check, size: 16, color: Colors.white)
                      : Text(
                          '${index + 1}',
                          style: TextStyle(
                            color: isCurrent
                                ? Theme.of(context).colorScheme.onPrimary
                                : Theme.of(context)
                                      .colorScheme
                                      .onSurfaceVariant,
                          ),
                        ),
                ),
                const SizedBox(height: 6),
                Text(
                  labels[index],
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
