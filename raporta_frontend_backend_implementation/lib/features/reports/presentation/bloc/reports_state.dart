import 'package:equatable/equatable.dart';

import '../../domain/entities/report.dart';
import '../../../../core/enums/report_category.dart';
import '../../../../core/enums/report_status.dart';

enum ReportsStatus {
  initial,
  loading,
  loaded,
  empty,
  failure,
}

class ReportsState extends Equatable {
  final ReportsStatus status;

  final List<Report> allReports;
  final List<Report> reports;

  final String searchQuery;
  final ReportCategory? selectedCategory;
  final ReportStatus? selectedStatus;

  final String? errorMessage;

  const ReportsState({
    this.status = ReportsStatus.initial,
    this.allReports = const [],
    this.reports = const [],
    this.searchQuery = '',
    this.selectedCategory,
    this.selectedStatus,
    this.errorMessage,
  });

  ReportsState copyWith({
    ReportsStatus? status,
    List<Report>? allReports,
    List<Report>? reports,
    String? searchQuery,
    ReportCategory? selectedCategory,
    ReportStatus? selectedStatus,
    String? errorMessage,
    bool clearCategory = false,
    bool clearStatus = false,
    bool clearError = false,
  }) {
    return ReportsState(
      status: status ?? this.status,
      allReports: allReports ?? this.allReports,
      reports: reports ?? this.reports,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory:
          clearCategory ? null : selectedCategory ?? this.selectedCategory,
      selectedStatus:
          clearStatus ? null : selectedStatus ?? this.selectedStatus,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        allReports,
        reports,
        searchQuery,
        selectedCategory,
        selectedStatus,
        errorMessage,
      ];
}

