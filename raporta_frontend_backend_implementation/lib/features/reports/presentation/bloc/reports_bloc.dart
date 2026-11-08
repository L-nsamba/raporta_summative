import 'package:flutter_bloc/flutter_bloc.dart';

import '../../domain/entities/report.dart';
import '../../domain/usecases/get_reports.dart';

import '../../../../core/enums/report_category.dart';
import '../../../../core/enums/report_status.dart';

import 'reports_event.dart';
import 'reports_state.dart';

class ReportsBloc extends Bloc<ReportsEvent, ReportsState> {
  final GetReports getReports;

  ReportsBloc({required this.getReports}) : super(const ReportsState()) {
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

  // FETCH REPORTS FROM REPOSITORY

  Future<void> _fetchReports(Emitter<ReportsState> emit) async {
    try {
      final reports = await getReports();

      final filteredReports = _applyFilters(
        reports,
        searchQuery: state.searchQuery,
        category: state.selectedCategory,
        status: state.selectedStatus,
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
    );

    emit(
      state.copyWith(
        reports: filteredReports,
        selectedCategory: event.category,
        selectedStatus: event.status,
        clearCategory: event.category == null,
        clearStatus: event.status == null,
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
    );

    emit(
      state.copyWith(
        reports: filteredReports,
        searchQuery: '',
        clearCategory: true,
        clearStatus: true,
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
  }) {
    final query = searchQuery.trim().toLowerCase();

    return reports.where((report) {
      final matchesSearch =
          query.isEmpty ||
          report.description.toLowerCase().contains(query) ||
          (report.locationDescription).toLowerCase().contains(query);
      final matchesCategory = category == null || report.category == category;

      final matchesStatus = status == null || report.status == status;

      return matchesSearch && matchesCategory && matchesStatus;
    }).toList();
  }
}

