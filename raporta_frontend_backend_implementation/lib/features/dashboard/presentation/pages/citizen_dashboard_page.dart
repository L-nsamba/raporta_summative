import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:raporta_frontend_backend_implementation/app/dependency_injection/injection_container.dart';
import 'package:raporta_frontend_backend_implementation/app/router/route_names.dart';
import 'package:raporta_frontend_backend_implementation/core/widgets/app_drawer.dart';
import 'package:raporta_frontend_backend_implementation/core/widgets/empty_state.dart';
import 'package:raporta_frontend_backend_implementation/core/widgets/loading_indicator.dart';
import 'package:raporta_frontend_backend_implementation/core/widgets/report_card.dart';
import 'package:raporta_frontend_backend_implementation/core/widgets/stat_card.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/entities/app_user.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/presentation/bloc/auth_event.dart';
import 'package:raporta_frontend_backend_implementation/features/dashboard/domain/entities/citizen_dashboard_stats.dart';
import 'package:raporta_frontend_backend_implementation/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/dashboard/presentation/bloc/dashboard_state.dart';

class CitizenDashboardPage extends StatelessWidget {
  const CitizenDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    // AuthBloc provided globally by RaportaApp
    final user = context.select<AuthBloc, AppUser?>((bloc) => bloc.state.user);

    if (user == null) {
      return Scaffold(
        body: LoadingIndicator(message: 'Loading your account...'),
      );
    }

    // Keeping the dashboard Cubit scoped to the page
    return BlocProvider<DashboardCubit>(
      key: ValueKey('${user.userId}_${user.areaId}'),
      create: (_) =>
          sl<DashboardCubit>()
            ..loadCitizenDashboard(userId: user.userId, areaId: user.areaId),
      child: _CitizenDashboardView(user: user),
    );
  }
}

class _CitizenDashboardView extends StatelessWidget {
  final AppUser user;
  const _CitizenDashboardView({required this.user});

  Future<void> _refreshDashboard(BuildContext context) {
    return context.read<DashboardCubit>().loadCitizenDashboard(
      userId: user.userId,
      areaId: user.areaId,
    );
  }

  void _navigateFromDrawer(
    BuildContext context,
    AppDrawerDestination destination,
  ) {
    switch (destination) {
      case AppDrawerDestination.dashboard:
        context.go(RouteNames.citizenDashboard);
        break;

      case AppDrawerDestination.exploreReports:
        context.go(RouteNames.reports);
        break;

      case AppDrawerDestination.createReport:
        context.go(RouteNames.createReport);
        break;

      case AppDrawerDestination.myReports:
        context.go(RouteNames.myReports);
        break;

      case AppDrawerDestination.reportQueue:
        // Official-only destination.
        break;

      case AppDrawerDestination.manageReports:
        // Official-only destination.
        break;

      case AppDrawerDestination.notifications:
        context.go(RouteNames.notifications);
        break;

      case AppDrawerDestination.profile:
        context.go(RouteNames.profile);
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh dashboard',
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshDashboard(context),
          ),
        ],
      ),

      drawer: AppDrawer(
        role: user.role,
        userName: user.name,
        userEmail: user.email,
        selectedDestination: AppDrawerDestination.dashboard,
        onDestinationSelected: (destination) {
          _navigateFromDrawer(context, destination);
        },
        onSignOut: () {
          context.read<AuthBloc>().add(AuthLogoutRequested());
        },
      ),

      body: BlocBuilder<DashboardCubit, DashboardState>(
        builder: ((context, state) {
          if (state.status == DashboardStatus.loading ||
              state.status == DashboardStatus.initial) {
            return const LoadingIndicator(message: 'Loading your dashboard...');
          }

          if (state.status == DashboardStatus.failure) {
            return EmptyState(
              icon: Icons.error_outline,
              title: 'Unable to load dashboard',
              message:
                  state.errorMessage ??
                  'Something went wrong while loading your dashboard.',
              actionLabel: 'Try Again',
              onAction: () => _refreshDashboard(context),
            );
          }

          final stats = state.citizenStats;

          if (stats == null) {
            return EmptyState(
              icon: Icons.dashboard_outlined,
              title: 'Dashboard unavailable',
              message: 'Your dashboard information is not yet available',
              actionLabel: 'Refresh',
              onAction: () => _refreshDashboard(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () => _refreshDashboard(context),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Welcome, ${user.name}',
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Stay informed about reports in your community.',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),

                const SizedBox(height: 22),

                _CitizenDashboardStatistics(stats: stats),

                const SizedBox(height: 24),

                // Primary citizen action
                FilledButton.icon(
                  onPressed: () {
                    context.go(RouteNames.createReport);
                  },
                  icon: const Icon(Icons.add_circle_outline),
                  label: const Text('Report an issue'),
                ),

                const SizedBox(height: 28),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        'Lateset Reports in Your Area',
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    TextButton(
                      onPressed: () {
                        context.go(RouteNames.reports);
                      },
                      child: const Text('See All'),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                if (stats.latestReports.isEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: EmptyState(
                      icon: Icons.description_outlined,
                      title: 'No community reports yet',
                      message:
                          'Approved reports in your area will appear here.',
                    ),
                  )
                else
                  ...stats.latestReports.map(
                    (report) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ReportCard(
                        report: report,
                        onTap: () {
                          final path = RouteNames.reportDetails.replaceFirst(
                            ':reportId',
                            Uri.encodeComponent(report.reportId),
                          );

                          context.push(path);
                        },
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
              ],
            ),
          );
        }),
      ),
    );
  }
}

class _CitizenDashboardStatistics extends StatelessWidget {
  final CitizenDashboardStats stats;

  const _CitizenDashboardStatistics({required this.stats});

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisExtent: 140,
      ),
      children: [
        StatCard(
          title: 'Total Reports in Your Area',
          value: stats.totalReportsInArea,
          icon: Icons.description_outlined,
        ),
        StatCard(
          title: 'Resolved in Your Area',
          value: stats.resolvedReportsInArea,
          icon: Icons.check_circle_outline,
          color: Colors.green,
        ),
        StatCard(
          title: 'Active Reports in Your Area',
          value: stats.activeReportsInArea,
          icon: Icons.pending_actions_outlined,
          color: Colors.orange,
        ),
        StatCard(
          title: 'My Reports',
          value: stats.myReports,
          icon: Icons.person_outline,
        ),
      ],
    );
  }
}
