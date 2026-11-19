import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/dependency_injection/injection_container.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';
import '../bloc/dashboard_cubit.dart';
import '../bloc/dashboard_state.dart';

import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../../../auth/presentation/bloc/auth_event.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/stat_card.dart';
import '../../domain/entities/official_dashboard_stats.dart';
import '../widgets/weekly_reports_chart.dart';
import '../widgets/latest_report_tile.dart';
import '../../../reports/domain/entities/report.dart';

// Provides a DashboardCubit to the dashboard UI.
class OfficialDashboardPage extends StatelessWidget {
  const OfficialDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<DashboardCubit>(
      create: (_) => sl<DashboardCubit>()..loadOfficialDashboard(),
      child: const OfficialDashboardView(),
    );
  }
}

// Displays the dashboard based on its current state.
class OfficialDashboardView extends StatelessWidget {
  const OfficialDashboardView({super.key});

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

  Widget _buildStatisticsSection(
    BuildContext context,
    OfficialDashboardStats stats,
  ) {
    final cards = [
      (
        title: 'Pending Reports',
        value: stats.pendingReports,
        icon: Icons.pending_actions_outlined,
        color: AppColors.statusPending,
        route: RouteNames.reportQueue,
      ),
      (
        title: 'Under Review',
        value: stats.underReviewReports,
        icon: Icons.rate_review_outlined,
        color: AppColors.statusUnderReview,
        route: null,
      ),
      (
        title: 'Forwarded',
        value: stats.forwardedReports,
        icon: Icons.send_outlined,
        color: AppColors.statusForwarded,
        route: null,
      ),
      (
        title: 'Resolved',
        value: stats.resolvedReports,
        icon: Icons.check_circle_outline,
        color: AppColors.statusResolved,
        route: null,
      ),
    ];

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Report Overview',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),

          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth >= 600 ? 4 : 2;

              const spacing = 12.0;
              final cardWidth =
                  (constraints.maxWidth - spacing * (columns - 1)) / columns;

              return Wrap(
                spacing: spacing,
                runSpacing: spacing,
                children: [
                  for (final card in cards)
                    SizedBox(
                      width: cardWidth,
                      child: Semantics(
                        button: card.route != null,
                        child: InkWell(
                          borderRadius: BorderRadius.circular(12),
                          onTap: card.route == null
                              ? null
                              : () => context.push(card.route!),
                          child: StatCard(
                            title: card.title,
                            value: card.value,
                            icon: card.icon,
                            color: card.color,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLatestReportsSection(
    BuildContext context,
    List<Report> reports,
  ) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section heading and navigation.
          Row(
            children: [
              Expanded(
                child: Text(
                  'Latest Reports',
                  style: theme.textTheme.titleLarge,
                ),
              ),

              TextButton(
                onPressed: () {
                  context.push(RouteNames.assignedReports);
                },
                child: const Text('View approved reports'),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Show an empty state if there are no reports.
          if (reports.isEmpty)
            const EmptyState(
              icon: Icons.description_outlined,
              title: 'No recent reports',
              message: 'No civic reports have been submitted yet.',
            )
          else
            // The use case already returns the newest five.
            for (final report in reports)
              LatestReportTile(
                key: ValueKey(report.reportId),
                report: report,
                onTap: () async {
                  final path = RouteNames.reviewReport.replaceFirst(
                    ':reportId',
                    Uri.encodeComponent(report.reportId),
                  );

                  await context.push(path);

                  // Refresh the dashboard when returning from details.
                  if (context.mounted) {
                    context.read<DashboardCubit>().loadOfficialDashboard();
                  }
                },
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // AuthBloc is already provided globally in app.dart.
    final user = context.watch<AuthBloc>().state.user;

    final officialName = user?.name ?? 'Official';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Official Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Notifications',
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              context.push(RouteNames.officialNotifications);
            },
          ),
        ],
      ),

      // Reuse the shared navigation drawer.
      drawer: user == null
          ? null
          : AppDrawer(
              role: user.role,
              userName: user.name,
              userEmail: user.email,
              selectedDestination: AppDrawerDestination.dashboard,
              onDestinationSelected: (destination) {
                _navigateToDestination(context, destination);
              },
              onSignOut: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            ),

      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Personalized welcome section.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: theme.colorScheme.primary,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Welcome, $officialName',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    color: theme.colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'Here is an overview of civic reports.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onPrimary.withValues(alpha: 0.85),
                  ),
                ),
              ],
            ),
          ),

          // Dashboard content from Step 1.
          Expanded(
            child: BlocBuilder<DashboardCubit, DashboardState>(
              builder: (context, state) {
                switch (state.status) {
                  case DashboardStatus.initial:
                  case DashboardStatus.loading:
                    return const LoadingIndicator(
                      message: 'Loading dashboard...',
                    );

                  case DashboardStatus.failure:
                    return EmptyState(
                      icon: Icons.error_outline,
                      title: 'Unable to load dashboard',
                      message:
                          state.errorMessage ??
                          'Something went wrong. Please try again.',
                      actionLabel: 'Retry',
                      onAction: () {
                        context.read<DashboardCubit>().loadOfficialDashboard();
                      },
                    );

                  case DashboardStatus.loaded:
                    final stats = state.officialStats;

                    if (stats == null) {
                      return const EmptyState(
                        icon: Icons.info_outline,
                        title: 'Dashboard data unavailable',
                        message: 'No dashboard statistics were returned.',
                      );
                    }

                    // Temporary content from Step 1.

                    return SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Section 1: Statistics cards
                          _buildStatisticsSection(context, stats),

                          // Section 2: Weekly reports chart
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16),
                            child: WeeklyReportsChart(
                              weeklyReports: stats.weeklyReports,
                            ),
                          ),

                          const SizedBox(height: 24),

                          // Section 3: Latest reports
                          _buildLatestReportsSection(
                            context,
                            stats.latestReports,
                          ),

                          const SizedBox(height: 24),
                        ],
                      ),
                    );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
