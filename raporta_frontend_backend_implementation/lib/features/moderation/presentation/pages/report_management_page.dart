import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../app/dependency_injection/injection_container.dart';
import '../../../../core/widgets/empty_state.dart';
import '../../../../core/widgets/loading_indicator.dart';

import '../../../areas/presentation/bloc/areas_cubit.dart';
import '../../../reports/presentation/bloc/reports_bloc.dart';
import '../../../reports/presentation/bloc/reports_event.dart';
import '../../../reports/presentation/bloc/reports_scope.dart';
import '../../../reports/presentation/bloc/reports_state.dart';
import '../../../areas/presentation/bloc/areas_state.dart';
import '../../../../core/enums/report_category.dart';
import '../../../../core/enums/report_status.dart';

import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../widgets/approved_report_card.dart';

class ReportManagementPage extends StatelessWidget {
  const ReportManagementPage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        // Retrieve approved reports only.
        BlocProvider<ReportsBloc>(
          create: (_) =>
              sl<ReportsBloc>(param1: ReportsScope.approved)
                ..add(const LoadReports()),
        ),

        // Retrieve available areas for filtering.
        BlocProvider<AreasCubit>(create: (_) => sl<AreasCubit>()..fetchAreas()),
      ],
      child: const ReportManagementView(),
    );
  }
}

class ReportManagementView extends StatefulWidget {
  const ReportManagementView({super.key});

  @override
  State<ReportManagementView> createState() => _ReportManagementViewState();
}

class _ReportManagementViewState extends State<ReportManagementView> {
  final TextEditingController _searchController = TextEditingController();

  Widget _buildAreaFilters(BuildContext context) {
    return BlocBuilder<AreasCubit, AreasState>(
      builder: (context, areasState) {
        switch (areasState.status) {
          case AreasStatus.initial:
          case AreasStatus.loading:
            return const LinearProgressIndicator();

          case AreasStatus.failure:
            return Row(
              children: [
                const Expanded(child: Text('Unable to load areas.')),
                TextButton(
                  onPressed: () {
                    context.read<AreasCubit>().fetchAreas();
                  },
                  child: const Text('Retry'),
                ),
              ],
            );

          case AreasStatus.success:
            // Use actual areas from the repository.
            final areas = areasState.areas.where((area) {
              final name = area.name.trim().toLowerCase();
              return name == 'remera' || name == 'kimironko';
            }).toList();

            return BlocBuilder<ReportsBloc, ReportsState>(
              builder: (context, reportsState) {
                final selectedAreaId = reportsState.selectedAreaId;

                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    // Null means all areas.
                    ChoiceChip(
                      label: const Text('All Areas'),
                      selected: selectedAreaId == null,
                      onSelected: (_) {
                        _filterByArea(null);
                      },
                    ),

                    // Create a chip for each actual area.
                    for (final area in areas)
                      ChoiceChip(
                        label: Text(area.name),
                        selected: selectedAreaId == area.areaId,
                        onSelected: (_) {
                          _filterByArea(area.areaId);
                        },
                      ),
                  ],
                );
              },
            );
        }
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _searchReports(String query) {
    setState(() {
      // Rebuild to update the search field's clear icon.
    });

    context.read<ReportsBloc>().add(SearchReports(query));
  }

  void _filterByArea(String? selectedAreaId) {
    final bloc = context.read<ReportsBloc>();

    bloc.add(
      FilterReports(
        areaId: selectedAreaId,

        // Preserve the other selected filters.
        category: bloc.state.selectedCategory,
        status: bloc.state.selectedStatus,
      ),
    );
  }

  void _filterByStatus(ReportStatus? selectedStatus) {
    final bloc = context.read<ReportsBloc>();

    bloc.add(
      FilterReports(
        // Preserve the existing area and category filters.
        areaId: bloc.state.selectedAreaId,
        category: bloc.state.selectedCategory,
        status: selectedStatus,
      ),
    );
  }

  void _filterByCategory(ReportCategory? selectedCategory) {
    final bloc = context.read<ReportsBloc>();

    bloc.add(
      FilterReports(
        // Preserve the existing area and status filters.
        areaId: bloc.state.selectedAreaId,
        category: selectedCategory,
        status: bloc.state.selectedStatus,
      ),
    );
  }

  void _clearAllFilters() {
    _searchController.clear();

    setState(() {
      // Refresh the search field decoration.
    });

    context.read<ReportsBloc>().add(const ClearReportFilters());
  }

  Widget _buildAdditionalFilters(BuildContext context) {
    return BlocBuilder<ReportsBloc, ReportsState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // STATUS FILTER
            Text(
              'Filter by status',
              style: Theme.of(context).textTheme.titleSmall,
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<ReportStatus>(
              key: ValueKey(state.selectedStatus),
              initialValue: state.selectedStatus,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.filter_list),
              ),
              hint: const Text('All Statuses'),

              items: const [
                DropdownMenuItem<ReportStatus>(
                  value: null,
                  child: Text('All Statuses'),
                ),
                DropdownMenuItem<ReportStatus>(
                  value: ReportStatus.underReview,
                  child: Text('Under Review'),
                ),
                DropdownMenuItem<ReportStatus>(
                  value: ReportStatus.forwarded,
                  child: Text('Forwarded'),
                ),
                DropdownMenuItem<ReportStatus>(
                  value: ReportStatus.inProgress,
                  child: Text('In Progress'),
                ),
                DropdownMenuItem<ReportStatus>(
                  value: ReportStatus.resolved,
                  child: Text('Resolved'),
                ),
              ],

              onChanged: _filterByStatus,
            ),

            const SizedBox(height: 16),

            // CATEGORY FILTER
            Text(
              'Filter by category',
              style: Theme.of(context).textTheme.titleSmall,
            ),

            const SizedBox(height: 8),

            DropdownButtonFormField<ReportCategory>(
              key: ValueKey(state.selectedCategory),
              initialValue: state.selectedCategory,
              isExpanded: true,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.category_outlined),
              ),
              hint: const Text('All Categories'),

              items: [
                const DropdownMenuItem<ReportCategory>(
                  value: null,
                  child: Text('All Categories'),
                ),
                ...ReportCategory.values.map((category) {
                  return DropdownMenuItem<ReportCategory>(
                    value: category,
                    child: Text(category.displayName),
                  );
                }),
              ],

              onChanged: _filterByCategory,
            ),

            const SizedBox(height: 12),

            // CLEAR ALL FILTERS
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: _clearAllFilters,
                icon: const Icon(Icons.restart_alt),
                label: const Text('Clear Filters'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openReportDetails(String reportId) async {
    final reportsBloc = context.read<ReportsBloc>();

    final path = RouteNames.reviewReport.replaceFirst(
      ':reportId',
      Uri.encodeComponent(reportId),
    );

    await context.push(path);

    // Reload reports after returning from details.
    if (mounted && !reportsBloc.isClosed) {
      reportsBloc.add(const RefreshReports());
    }
  }

  @override
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Reports'),
        leading: IconButton(
          tooltip: 'Back to Dashboard',
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(RouteNames.officialDashboard);
            }
          },
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh approved reports',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context.read<ReportsBloc>().add(const RefreshReports());
            },
          ),
        ],
      ),

      body: BlocBuilder<ReportsBloc, ReportsState>(
        builder: (context, state) {
          return CustomScrollView(
            slivers: [
              // SEARCH AND FILTERS
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Search field

                      TextField(
                        controller: _searchController,
                        onChanged: _searchReports,
                        textInputAction: TextInputAction.search,
                        decoration: InputDecoration(
                          hintText: 'Search reports...',
                          prefixIcon: const Icon(Icons.search),

                          suffixIcon: _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _searchReports('');
                                  },
                                ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Area filters
                      Text('Filter by area', style: theme.textTheme.titleSmall),

                      const SizedBox(height: 10),

                      _buildAreaFilters(context),

                      const SizedBox(height: 20),

                      // Status, category and clear filters
                      _buildAdditionalFilters(context),

                      const SizedBox(height: 20),

                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Approved Reports',
                              style: theme.textTheme.titleLarge,
                            ),
                          ),

                          if (state.status == ReportsStatus.loaded ||
                              state.status == ReportsStatus.empty)
                            Text(
                              '${state.reports.length} results',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                        ],
                      ),

                      const SizedBox(height: 12),
                    ],
                  ),
                ),
              ),

              // LOADING STATE
              if (state.status == ReportsStatus.initial ||
                  state.status == ReportsStatus.loading)
                const SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: LoadingIndicator(
                      message: 'Loading approved reports...',
                    ),
                  ),
                ),

              // FAILURE STATE
              if (state.status == ReportsStatus.failure)
                SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.error_outline,
                    title: 'Unable to load reports',
                    message:
                        state.errorMessage ??
                        'Something went wrong. Please try again.',
                    actionLabel: 'Retry',
                    onAction: () {
                      context.read<ReportsBloc>().add(const LoadReports());
                    },
                  ),
                ),

              // EMPTY BASE LIST
              if (state.status == ReportsStatus.empty)
                const SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.inbox_outlined,
                    title: 'No approved reports',
                    message: 'There are currently no approved reports.',
                  ),
                ),

              // FILTERS RETURNED NO MATCHES
              if (state.status == ReportsStatus.loaded && state.reports.isEmpty)
                const SliverToBoxAdapter(
                  child: EmptyState(
                    icon: Icons.search_off_outlined,
                    title: 'No matching reports',
                    message: 'Try changing or clearing your filters.',
                  ),
                ),

              // APPROVED REPORTS LIST
              if (state.status == ReportsStatus.loaded &&
                  state.reports.isNotEmpty)
                SliverPadding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  sliver: SliverList.builder(
                    itemCount: state.reports.length,
                    itemBuilder: (context, index) {
                      final report = state.reports[index];

                      return ApprovedReportCard(
                        key: ValueKey(report.reportId),
                        report: report,
                        onViewDetails: () {
                          _openReportDetails(report.reportId);
                        },
                      );
                    },
                  ),
                ),

              // Bottom spacing
              const SliverToBoxAdapter(child: SizedBox(height: 24)),
            ],
          );
        },
      ),
    );
  }
}
