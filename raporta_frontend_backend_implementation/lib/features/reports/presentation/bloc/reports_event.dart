import 'package:equatable/equatable.dart';

import '../../../../core/enums/report_category.dart';
import '../../../../core/enums/report_status.dart';

abstract class ReportsEvent extends Equatable {
  const ReportsEvent();

  @override
  List<Object?> get props => [];
}

class LoadReports extends ReportsEvent {
  const LoadReports();
}

class RefreshReports extends ReportsEvent {
  const RefreshReports();
}

class SearchReports extends ReportsEvent {
  final String query;

  const SearchReports(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterReports extends ReportsEvent {
  final ReportCategory? category;
  final ReportStatus? status;
  final String? areaId;

  const FilterReports({this.category, this.status, this.areaId});

  @override
  List<Object?> get props => [category, status, areaId];
}

class ClearReportFilters extends ReportsEvent {
  const ClearReportFilters();
}
