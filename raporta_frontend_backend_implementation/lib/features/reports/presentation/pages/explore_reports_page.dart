import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:raporta_frontend_backend_implementation/app/dependency_injection/injection_container.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_category.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/presentation/bloc/auth_event.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/bloc/reports_scope.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/pages/explore_reports_map.dart';

import '../../../../app/router/route_names.dart';
import '../../../../core/widgets/app_drawer.dart';
import '../../../../core/widgets/report_card.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';
import '../bloc/reports_bloc.dart';
import '../bloc/reports_event.dart';
import '../bloc/reports_state.dart';

class ExploreReportsPage extends StatelessWidget {
  const ExploreReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<ReportsBloc>(
      create: (_) =>
          sl<ReportsBloc>(param1: ReportsScope.public)..add(LoadReports()),
      child: const _ExploreReportsView(),
    );
  }
}

class _ExploreReportsView extends StatefulWidget {
  const _ExploreReportsView();

  @override
  State<_ExploreReportsView> createState() => __ExploreReportsViewState();
}

class __ExploreReportsViewState extends State<_ExploreReportsView> {
  final TextEditingController _searchController = TextEditingController();

  ReportCategory? _selectedCategory;
  ReportStatus? _selectedStatus;
  bool _showMapView = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _navigateFromDrawer(
    BuildContext context,
    AppDrawerDestination destination,
  ) {
    final route = switch (destination) {
      AppDrawerDestination.dashboard => RouteNames.citizenDashboard,

      AppDrawerDestination.exploreReports => RouteNames.reports,

      AppDrawerDestination.createReport => RouteNames.createReport,

      AppDrawerDestination.myReports => RouteNames.myReports,

      AppDrawerDestination.notifications => RouteNames.notifications,

      AppDrawerDestination.profile => RouteNames.profile,

      AppDrawerDestination.reportQueue ||
      AppDrawerDestination.manageReports => null,
    };

    if (route != null) {
      context.go(route);
    }
  }

  Future<void> _refresh(BuildContext context) async {
    context.read<ReportsBloc>().add(RefreshReports());
  }

  void _openReport(BuildContext context, String reportId) {
    final path = RouteNames.reportDetails.replaceFirst(
      ':reportId',
      Uri.encodeComponent(reportId),
    );

    context.push(path);
  }

  void _searchReports(String query) {
    context.read<ReportsBloc>().add(SearchReports(query.trim()));
  }

  void _applyFilters() {
    context.read<ReportsBloc>().add(
      FilterReports(
        category: _selectedCategory,
        status: _selectedStatus,
        areaId: null,
      ),
    );
  }

  void _clearFilters() {
    setState(() {
      _selectedCategory = null;
      _selectedStatus = null;
      _searchController.clear();
    });

    context.read<ReportsBloc>().add(ClearReportFilters());
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthBloc>().state.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Explore Reports'),
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (scaffoldContext) => IconButton(
            tooltip: 'Open navigation menu',
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(scaffoldContext).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh reports',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ReportsBloc>().add(RefreshReports());
            },
          ),
        ],
      ),

      drawer: user == null
          ? null
          : AppDrawer(
              role: user.role,
              userName: user.name,
              userEmail: user.email,
              selectedDestination: AppDrawerDestination.exploreReports,
              onDestinationSelected: (destination) {
                _navigateFromDrawer(context, destination);
              },
              onSignOut: () {
                context.read<AuthBloc>().add(AuthLogoutRequested());
              },
            ),

      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          switch (state.status) {
            case ReportsStatus.initial:
            case ReportsStatus.loading:
              return const Center(child: CircularProgressIndicator());

            case ReportsStatus.failure:
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48),
                      const SizedBox(height: 12),
                      Text(
                        state.errorMessage ?? 'Unable to load reports.',
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          context.read<ReportsBloc>().add(LoadReports());
                        },
                        child: const Text('Try Again'),
                      ),
                    ],
                  ),
                ),
              );

            case ReportsStatus.empty:
              return RefreshIndicator(
                onRefresh: () => _refresh(context),
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(24),
                  children: const [
                    SizedBox(height: 100),

                    Icon(
                      Icons.search_off_outlined,
                      size: 64,
                      color: Colors.grey,
                    ),

                    SizedBox(height: 16),

                    Center(
                      child: Text(
                        'No public reports yet',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    SizedBox(height: 8),

                    Center(
                      child: Text(
                        'Approved community reports will appear here.',
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );

            case ReportsStatus.loaded:
              final reports = state.reports;

              return Column(
                children: [
                  // Controls stay visible in both views.
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Community Reports',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 6),

                        Text(
                          'Explore reported issues and their progress.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),

                        const SizedBox(height: 16),

                        _buildViewToggle(),

                        const SizedBox(height: 16),

                        _buildSearchAndFilters(context),

                        const SizedBox(height: 8),

                        Text(
                          '${reports.length} reports found',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),

                  // Display either the report list or the map.
                  Expanded(
                    child: _showMapView
                        ? Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                            child: ExploreReportsMap(
                              reports: reports,
                              onReportSelected: (reportId) {
                                _openReport(context, reportId);
                              },
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () => _refresh(context),
                            child: ListView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: const EdgeInsets.all(16),
                              itemCount: reports.length,
                              itemBuilder: (context, index) {
                                final report = reports[index];

                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: ReportCard(
                                    report: report,
                                    onTap: () =>
                                        _openReport(context, report.reportId),
                                  ),
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
          }
        },
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context) {
    final theme = Theme.of(context);

    final publicStatuses = ReportStatus.values
        .where((status) => status.isPublic)
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search bar
        TextField(
          controller: _searchController,
          onChanged: _searchReports,
          decoration: InputDecoration(
            hintText: 'Search reports...',
            prefixIcon: const Icon(Icons.search),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            suffixIcon: IconButton(
              tooltip: 'Clear search',
              icon: const Icon(Icons.close),
              onPressed: () {
                _searchController.clear();
                _searchReports('');
              },
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Category and status dropdowns
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<ReportCategory>(
                initialValue: _selectedCategory,
                isExpanded: true,
                key: ValueKey('category-$_selectedCategory'),
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: [
                  const DropdownMenuItem<ReportCategory>(
                    value: null,
                    child: Text('All categories'),
                  ),
                  ...ReportCategory.values.map(
                    (category) => DropdownMenuItem(
                      value: category,
                      child: Text(
                        _formatEnumName(category.name),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (category) {
                  setState(() {
                    _selectedCategory = category;
                  });

                  _applyFilters();
                },
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: DropdownButtonFormField<ReportStatus>(
                initialValue: _selectedStatus,
                isExpanded: true,
                key: ValueKey('status-$_selectedStatus'),
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 12,
                  ),
                ),
                items: [
                  const DropdownMenuItem<ReportStatus>(
                    value: null,
                    child: Text('All statuses'),
                  ),
                  ...publicStatuses.map(
                    (status) => DropdownMenuItem(
                      value: status,
                      child: Text(
                        _formatEnumName(status.name),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (status) {
                  setState(() {
                    _selectedStatus = status;
                  });

                  _applyFilters();
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: _clearFilters,
            icon: const Icon(Icons.filter_alt_off_outlined),
            label: const Text('Clear Filters'),
            style: TextButton.styleFrom(
              foregroundColor: theme.colorScheme.primary,
            ),
          ),
        ),
      ],
    );
  }

  String _formatEnumName(String name) {
    final formatted = name.replaceAllMapped(
      RegExp(r'([a-z])([A-Z])'),
      (match) => '${match.group(1)} ${match.group(2)}',
    );

    return formatted[0].toUpperCase() + formatted.substring(1);
  }

  Widget _buildViewToggle() {
    return SegmentedButton<bool>(
      segments: const [
        ButtonSegment<bool>(
          value: false,
          icon: Icon(Icons.view_list_outlined),
          label: Text('List View'),
        ),
        ButtonSegment<bool>(
          value: true,
          icon: Icon(Icons.map_outlined),
          label: Text('Map View'),
        ),
      ],
      selected: {_showMapView},
      onSelectionChanged: (selection) {
        setState(() {
          _showMapView = selection.first;
        });
      },
    );
  }
}
