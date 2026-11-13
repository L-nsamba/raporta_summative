import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/get_public_reports.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/bloc/reports_scope.dart';

import '../../domain/entities/report.dart';
import '../../domain/usecases/get_reports.dart';

import '../../../../core/enums/report_category.dart';
import '../../../../core/enums/report_status.dart';

import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetReports getReports;
  final GetPublicReports getPublicReports;
  final ReportsScope scope;
  int _requestId = 0;

  ReportsBloc({
    required this.getReports,
    required this.getPublicReports,
    required this.scope,
  }) : super(const ReportsState()) {
    on<LoadReports>(_onLoadReports);
    on<RefreshReports>(_onRefreshReports);
    on<SearchReports>(_onSearchReports);
    on<FilterReports>(_onFilterReports);
    on<ClearReportFilters>(_onClearReportFilters);
  }

  // LOAD REPORTS

  Future<void> _onLoadReports(
    LoadReports event,
    Emitter<ReportsState> emit,
  ) async {
    emit(state.copyWith(status: ReportsStatus.loading, clearError: true));

    await _fetchReports(emit);
  }

  // REFRESH REPORTS

  Future<void> _onRefreshReports(
    RefreshReports event,
    Emitter<ReportsState> emit,
  ) async {
    await _fetchReports(emit);
  }

  // RETRIEVE REPORTS BASED ON SCREEN SCOPE

  Future<List<Report>> _getScopedReports() async {
    switch (scope) {
      case ReportsScope.public:
        return getPublicReports();

      case ReportsScope.all:
        return getReports();

      case ReportsScope.pending:
        final reports = await getReports();

        return reports
            .where((report) => report.status == ReportStatus.pending)
            .toList();

      case ReportsScope.approved:
        final reports = await getReports();

        return reports.where((report) => report.status.isPublic).toList();
    }
  }

  // FETCH REPORTS FROM REPOSITORY

  Future<void> _fetchReports(Emitter<ReportsState> emit) async {
    final requestId = ++_requestId;

    try {
      final reports = await _getScopedReports();

      // Ignore outdated requests or cancelled handlers.
      if (requestId != _requestId || emit.isDone || isClosed) {
        return;
      }

      final filteredReports = _applyFilters(
        reports,
        searchQuery: state.searchQuery,
        category: state.selectedCategory,
        status: state.selectedStatus,
        areaId: state.selectedAreaId,
      );

      emit(
        state.copyWith(
          status: reports.isEmpty ? ReportsStatus.empty : ReportsStatus.loaded,
          allReports: reports,
          reports: filteredReports,
          clearError: true,
        ),
      );
    } catch (e) {
      // An older failed request must not overwrite newer data.
      if (requestId != _requestId || emit.isDone || isClosed) {
        return;
      }

      emit(
        state.copyWith(
          status: ReportsStatus.failure,
          errorMessage: 'Unable to load reports. Please try again.',
        ),
      );
    }
  }

  // SEARCH REPORTS

  void _onSearchReports(SearchReports event, Emitter<ReportsState> emit) {
    final filteredReports = _applyFilters(
      state.allReports,
      searchQuery: event.query,
      category: state.selectedCategory,
      status: state.selectedStatus,
      areaId: state.selectedAreaId,
    );

    emit(
      state.copyWith(
        reports: filteredReports,
        searchQuery: event.query,
        clearError: true,
      ),
    );
  }

  // FILTER REPORTS

  void _onFilterReports(FilterReports event, Emitter<ReportsState> emit) {
    final filteredReports = _applyFilters(
      state.allReports,
      searchQuery: state.searchQuery,
      category: event.category,
      status: event.status,
      areaId: event.areaId,
    );

    emit(
      state.copyWith(
        reports: filteredReports,
        selectedCategory: event.category,
        selectedStatus: event.status,
        selectedAreaId: event.areaId,
        clearCategory: event.category == null,
        clearStatus: event.status == null,
        clearArea: event.areaId == null,
        clearError: true,
      ),
    );
  }

  // CLEAR FILTERS

  void _onClearReportFilters(
    ClearReportFilters event,
    Emitter<ReportsState> emit,
  ) {
    final filteredReports = _applyFilters(
      state.allReports,
      searchQuery: '',
      category: null,
      status: null,
      areaId: null,
    );

    emit(
      state.copyWith(
        reports: filteredReports,
        searchQuery: '',
        clearCategory: true,
        clearStatus: true,
        clearArea: true,
        clearError: true,
      ),
    );
  }

  // LOCAL SEARCH AND FILTER LOGIC

  List<Report> _applyFilters(
    List<Report> reports, {
    required String searchQuery,
    ReportCategory? category,
    ReportStatus? status,
    String? areaId,
  }) {
    final query = searchQuery.trim().toLowerCase();

    return reports.where((report) {
      final matchesSearch =
          query.isEmpty ||
          report.description.toLowerCase().contains(query) ||
          report.locationDescription.toLowerCase().contains(query);

      final matchesCategory = category == null || report.category == category;

      final matchesStatus = status == null || report.status == status;

      final matchesArea = areaId == null || report.areaId == areaId;

      return matchesSearch && matchesCategory && matchesStatus && matchesArea;
    }).toList();
  }
}
