import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/dependency_injection/injection_container.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';

import '../../../reports/presentation/bloc/reports_bloc.dart';
import '../../../reports/presentation/bloc/reports_event.dart';
import '../../../reports/presentation/bloc/reports_scope.dart';
import '../../../reports/presentation/bloc/reports_state.dart';

import 'package:go_router/go_router.dart';

import '../cubit/moderation_state.dart';
import '../widgets/approval_confirmation_dialog.dart';
import '../../../../core/widgets/app_snackbar.dart';
import '../widgets/decline_reason_dialog.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_drawer.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../widgets/pending_report_card.dart';

import '../cubit/moderation_cubit.dart';

class ReportModerationPage extends StatelessWidget {
  const ReportModerationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Retrieve only pending reports.
        BlocProvider<ReportsBloc>(
          create: (_) =>
              sl<ReportsBloc>(param1: ReportsScope.pending)
                ..add(const LoadReports()),
        ),

        // Handles approval and decline operations.
        BlocProvider<ModerationCubit>(create: (_) => sl<ModerationCubit>()),
      ],
      child: const ReportQueueView(),
    );
  }
}

class ReportQueueView extends StatelessWidget {
  const ReportQueueView({super.key});

  Future<void> _showApprovalDialog(
    BuildContext context,
    String reportId,
  ) async {
    final moderationCubit = context.read<ModerationCubit>();

    // Avoid starting another action while one is running.
    if (moderationCubit.state.status == ModerationStatus.submitting) {
      return;
    }

    // Clear any previous moderation result.
    moderationCubit.reset();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: moderationCubit,
          child: ApprovalConfirmationDialog(
            reportId: reportId,
            onApproved: () {
              if (!context.mounted) return;

              // Reload pending reports after successful approval.
              context.read<ReportsBloc>().add(const RefreshReports());

              AppSnackbar.show(
                context,
                message: 'Report approved successfully.',
                type: SnackbarType.success,
              );
            },
          ),
        );
      },
    );
  }

  Future<void> _showDeclineDialog(BuildContext context, String reportId) async {
    final moderationCubit = context.read<ModerationCubit>();

    // Prevent opening another action during submission.
    if (moderationCubit.state.status == ModerationStatus.submitting) {
      return;
    }

    // Clear previous success or failure results.
    moderationCubit.reset();

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: moderationCubit,
          child: DeclineReasonDialog(
            reportId: reportId,
            onDeclined: () {
              if (!context.mounted) return;

              // Refresh the pending report queue.
              context.read<ReportsBloc>().add(const RefreshReports());

              AppSnackbar.show(
                context,
                message: 'Report declined successfully.',
                type: SnackbarType.success,
              );
            },
          ),
        );
      },
    );
  }

  void _navigateToDestination(
    BuildContext context,
    AppDrawerDestination destination,
  ) {
    final route = switch (destination) {
      AppDrawerDestination.dashboard => RouteNames.officialDashboard,

      AppDrawerDestination.reportQueue => RouteNames.reportQueue,

      AppDrawerDestination.manageReports => RouteNames.assignedReports,

      AppDrawerDestination.notifications => RouteNames.officialNotifications,

      AppDrawerDestination.profile => RouteNames.profile,

      // Citizen-only destinations.
      AppDrawerDestination.exploreReports ||
      AppDrawerDestination.createReport ||
      AppDrawerDestination.myReports => null,
    };

    if (route != null) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;
    return Scaffold(
      drawer: user == null
          ? null
          : AppDrawer(
              role: user.role,
              userName: user.name,
              userEmail: user.email,
              selectedDestination: AppDrawerDestination.reportQueue,
              onDestinationSelected: (destination) {
                _navigateToDestination(context, destination);
              },
              onSignOut: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            ),

      appBar: AppBar(
        title: const Text('Report Queue'),
        actions: [
          IconButton(
            tooltip: 'Refresh pending reports',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              if (context.read<ModerationCubit>().state.status ==
                  ModerationStatus.submitting) {
                return;
              }

              context.read<ReportsBloc>().add(const RefreshReports());
            },
          ),
        ],
      ),
      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          switch (state.status) {
            case ReportsStatus.initial:
            case ReportsStatus.loading:
              return const LoadingIndicator(
                message: 'Loading pending reports...',
              );

            case ReportsStatus.failure:
              return EmptyState(
                icon: Icons.error_outline,
                title: 'Unable to load reports',
                message:
                    state.errorMessage ??
                    'Something went wrong. Please try again.',
                actionLabel: 'Retry',
                onAction: () {
                  context.read<ReportsBloc>().add(const LoadReports());
                },
              );

            case ReportsStatus.empty:
              return const EmptyState(
                icon: Icons.inbox_outlined,
                title: 'No pending reports',
                message: 'There are currently no reports awaiting approval.',
              );

            case ReportsStatus.loaded:
              final reports = state.reports;

              if (reports.isEmpty) {
                return const EmptyState(
                  icon: Icons.search_off_outlined,
                  title: 'No matching reports',
                  message: 'No pending reports match the current filters.',
                );
              }

              // Temporary content for Stage 1.
              // We'll replace this with report cards in Stage 2.

              return BlocBuilder<ModerationCubit, ModerationState>(
                builder: (context, moderationState) {
                  final isSubmitting =
                      moderationState.status == ModerationStatus.submitting;

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: reports.length,
                    itemBuilder: (context, index) {
                      final report = reports[index];

                      return PendingReportCard(
                        key: ValueKey(report.reportId),
                        report: report,

                        // Existing View Details navigation.
                        onViewDetails: () async {
                          final path = RouteNames.reviewReport.replaceFirst(
                            ':reportId',
                            Uri.encodeComponent(report.reportId),
                          );

                          await context.push(path);

                          if (context.mounted) {
                            context.read<ReportsBloc>().add(
                              const RefreshReports(),
                            );
                          }
                        },

                        // New approval action.
                        onApprove: isSubmitting
                            ? null
                            : () {
                                _showApprovalDialog(context, report.reportId);
                              },
                        onDecline: isSubmitting
                            ? null
                            : () {
                                _showDeclineDialog(context, report.reportId);
                              },
                      );
                    },
                  );
                },
              );
          }
        },
      ),
    );
  }
}
