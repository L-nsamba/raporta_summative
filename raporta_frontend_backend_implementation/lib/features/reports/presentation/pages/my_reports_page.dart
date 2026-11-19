import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:raporta_frontend_backend_implementation/app/dependency_injection/injection_container.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/report_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../cubit/my_reports_cubit.dart';
import '../cubit/my_reports_state.dart';

class MyReportsPage extends StatelessWidget {
  const MyReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthBloc>().state.user;

    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Please sign in to view your reports.')),
      );
    }

    return BlocProvider<MyReportsCubit>(
      create: (_) => sl<MyReportsCubit>()..loadMyReports(user.userId),
      child: _MyReportsView(userId: user.userId),
    );
  }
}

class _MyReportsView extends StatelessWidget {
  final String userId;

  const _MyReportsView({required this.userId});

  Future<void> _refresh(BuildContext context) async {
    await context.read<MyReportsCubit>().refreshReports(userId);
  }

  void _openReport(BuildContext context, String reportId) {
    final path = '/citizen/reports/${Uri.encodeComponent(reportId)}';

    context.push(path);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Reports'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go(RouteNames.citizenDashboard),
        ),
      ),
      body: BlocBuilder<MyReportsCubit, MyReportsState>(
        builder: (context, state) {
          switch (state.status) {
            case MyReportsStatus.initial:
            case MyReportsStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case MyReportsStatus.failure:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage ?? 'Unable to load your reports.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () => context
                            .read<MyReportsCubit>()
                            .loadMyReports(userId),
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );

            case MyReportsStatus.empty:
              return RefreshIndicator(
                onRefresh: () => _refresh(context),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    const SizedBox(height: 120),
                    const Icon(
                      Icons.description_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Center(
                      child: Text(
                        'No reports yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Center(
                      child: Text('Reports you submit will appear here.'),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () => context.push(RouteNames.createReport),
                        icon: const Icon(Icons.add),
                        label: const Text('Report an Issue'),
                      ),
                    ),
                  ],
                ),
              );

            case MyReportsStatus.loaded:
              return RefreshIndicator(
                onRefresh: () => _refresh(context),
                child: ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16),
                  itemCount: state.reports.length,
                  itemBuilder: (context, index) {
                    final report = state.reports[index];

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ReportCard(
                        report: report,
                        onTap: () => _openReport(context, report.reportId),
                      ),
                    );
                  },
                ),
              );
          }
        },
      ),
    );
  }
}
