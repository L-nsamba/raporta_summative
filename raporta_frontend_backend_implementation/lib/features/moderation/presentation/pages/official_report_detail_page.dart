import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/dependency_injection/injection_container.dart';
import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';

import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../reports/presentation/cubit/report_details_cubit.dart';
import '../../../reports/presentation/cubit/report_details_state.dart';
import '../../../areas/presentation/bloc/areas_cubit.dart';
import '../../../areas/presentation/bloc/areas_state.dart';
import '../widgets/report_progress_timeline.dart';
import '../widgets/approval_confirmation_dialog.dart';
import '../../../../core/enums/report_status.dart';
import '../widgets/moderation_confirmation_dialog.dart';
import '../widgets/forward_agency_dialog.dart';

import '../cubit/moderation_state.dart';
import '../widgets/decline_reason_dialog.dart';

import '../widgets/report_information_section.dart';
import '../widgets/moderation_action_buttons.dart';

import '../cubit/moderation_cubit.dart';

class OfficialReportDetailPage extends StatelessWidget {
  final String reportId;

  const OfficialReportDetailPage({super.key, required this.reportId});

  @override
  Widget build(BuildContext context) {
    // AuthBloc is already provided globally in app.dart.
    final user = context.watch<AuthBloc>().state.user;

    if (user == null) {
      return const Scaffold(
        body: EmptyState(
          icon: Icons.person_off_outlined,
          title: 'Authentication required',
          message: 'Please sign in to view this report.',
        ),
      );
    }

    return MultiBlocProvider(
      providers: [
        // Loads the selected report.
        BlocProvider<ReportDetailsCubit>(
          create: (_) =>
              sl<ReportDetailsCubit>()
                ..loadReportDetails(reportId: reportId, userId: user.userId),
        ),

        // Handles report moderation actions.
        BlocProvider<ModerationCubit>(create: (_) => sl<ModerationCubit>()),

        // Loads area names for readable location information.
        BlocProvider<AreasCubit>(create: (_) => sl<AreasCubit>()..fetchAreas()),
      ],

      child: OfficialReportDetailView(reportId: reportId, userId: user.userId),
    );
  }
}

class OfficialReportDetailView extends StatelessWidget {
  final String reportId;
  final String userId;

  const OfficialReportDetailView({
    super.key,
    required this.reportId,
    required this.userId,
  });

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      // Fallback when the page was opened directly.
      context.go(RouteNames.assignedReports);
    }
  }

  String? _resolveAreaName(AreasState areasState, String reportAreaId) {
    if (areasState.status != AreasStatus.success) {
      return null;
    }

    for (final area in areasState.areas) {
      if (area.areaId == reportAreaId) {
        return area.name;
      }
    }

    return null;
  }

  void _showApprovalDialog(BuildContext context) {
    final moderationCubit = context.read<ModerationCubit>();
    final detailsCubit = context.read<ReportDetailsCubit>();

    // Don't open another action while a request is running.
    if (moderationCubit.state.status == ModerationStatus.submitting) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: moderationCubit,
        child: ApprovalConfirmationDialog(
          reportId: reportId,
          onApproved: () {
            _refreshAfterModeration(detailsCubit);
          },
        ),
      ),
    );
  }

  void _showDeclineDialog(BuildContext context) {
    final moderationCubit = context.read<ModerationCubit>();
    final detailsCubit = context.read<ReportDetailsCubit>();

    if (moderationCubit.state.status == ModerationStatus.submitting) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: moderationCubit,
        child: DeclineReasonDialog(
          reportId: reportId,
          onDeclined: () {
            _refreshAfterModeration(detailsCubit);
          },
        ),
      ),
    );
  }

  void _showStatusUpdateDialog(
    BuildContext context, {
    required ReportStatus targetStatus,
    required String title,
    required String message,
    required String confirmLabel,
  }) {
    final moderationCubit = context.read<ModerationCubit>();
    final detailsCubit = context.read<ReportDetailsCubit>();

    if (moderationCubit.state.status == ModerationStatus.submitting) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: moderationCubit,
        child: ModerationConfirmationDialog(
          reportId: reportId,
          targetStatus: targetStatus,
          title: title,
          message: message,
          confirmLabel: confirmLabel,
          onSuccess: () {
            _refreshAfterModeration(detailsCubit);
          },
        ),
      ),
    );
  }

  void _showForwardAgencyDialog(BuildContext context) {
    final moderationCubit = context.read<ModerationCubit>();
    final detailsCubit = context.read<ReportDetailsCubit>();

    if (moderationCubit.state.status == ModerationStatus.submitting) {
      return;
    }

    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => BlocProvider.value(
        value: moderationCubit,
        child: ForwardAgencyDialog(
          reportId: reportId,
          onForwarded: () {
            _refreshAfterModeration(detailsCubit);
          },
        ),
      ),
    );
  }

  void _refreshAfterModeration(ReportDetailsCubit detailsCubit) {
    if (detailsCubit.isClosed) return;

    detailsCubit.refreshReportDetails(reportId: reportId, userId: userId);
  }

  
@override
Widget build(BuildContext context) {
  return BlocBuilder<ModerationCubit, ModerationState>(
    builder: (context, moderationState) {
      final isSubmitting =
          moderationState.status == ModerationStatus.submitting;

      return PopScope(
        canPop: !isSubmitting,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Report Details'),
            leading: IconButton(
              tooltip: 'Back',
              icon: const Icon(Icons.arrow_back),
              onPressed: isSubmitting ? null : () => _goBack(context),
            ),
          ),

          body: BlocBuilder<ReportDetailsCubit, ReportDetailsState>(
            builder: (context, state) {
              switch (state.status) {
                case ReportDetailsStatus.initial:
                case ReportDetailsStatus.loading:
                  return const LoadingIndicator(
                    message: 'Loading report details...',
                  );

                case ReportDetailsStatus.notFound:
                  return const EmptyState(
                    icon: Icons.search_off_outlined,
                    title: 'Report not found',
                    message: 'This report may have been deleted or is unavailable.',
                  );

                case ReportDetailsStatus.failure:
                  return EmptyState(
                    icon: Icons.error_outline,
                    title: 'Unable to load report',
                    message:
                        state.errorMessage ??
                        'Something went wrong. Please try again.',
                    actionLabel: 'Retry',
                    onAction: () {
                      context.read<ReportDetailsCubit>().loadReportDetails(
                        reportId: reportId,
                        userId: userId,
                      );
                    },
                  );

                case ReportDetailsStatus.loaded:
                  final report = state.report;

                  // Handle a missing report safely.
                  if (report == null) {
                    return const EmptyState(
                      icon: Icons.info_outline,
                      title: 'Report unavailable',
                      message:
                          'The report information could not be displayed.',
                    );
                  }

                  return BlocBuilder<AreasCubit, AreasState>(
                    builder: (context, areasState) {
                      final areaName = _resolveAreaName(
                        areasState,
                        report.areaId,
                      );

                      return SingleChildScrollView(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Stage 2: Report information
                            ReportInformationSection(
                              report: report,
                              areaName: areaName,
                            ),

                            const SizedBox(height: 24),

                            // Stage 3: Report progress timeline
                            ReportProgressTimeline(
                              report: report,
                            ),

                            const SizedBox(height: 24),

                            // Stage 4: Moderation action buttons
                            ModerationActionButtons(
                              status: report.status,
                              isSubmitting: isSubmitting,

                              // PENDING -> UNDER REVIEW
                              onApprove: () {
                                _showApprovalDialog(context);
                              },

                              // Nonterminal status -> DECLINED
                              onDecline: () {
                                _showDeclineDialog(context);
                              },

                              // UNDER REVIEW -> FORWARDED
                              onForward: () {
                                _showForwardAgencyDialog(context);
                              },

                              // FORWARDED -> IN PROGRESS
                              onMarkInProgress: () {
                                _showStatusUpdateDialog(
                                  context,
                                  targetStatus: ReportStatus.inProgress,
                                  title: 'Mark In Progress',
                                  message:
                                      'Are you sure you want to mark this report as In Progress?',
                                  confirmLabel: 'Confirm',
                                );
                              },

                              // IN PROGRESS -> RESOLVED
                              onMarkResolved: () {
                                _showStatusUpdateDialog(
                                  context,
                                  targetStatus: ReportStatus.resolved,
                                  title: 'Mark Resolved',
                                  message:
                                      'Are you sure this issue has been resolved?',
                                  confirmLabel: 'Mark Resolved',
                                );
                              },
                            ),

                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  );
              }
            },
          ),
        ),
      );
    },
  );
}
}
