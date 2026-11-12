import 'package:equatable/equatable.dart';

import '../../domain/entities/report.dart';
import '../../domain/entities/upvotes.dart';

enum ReportDetailsStatus {
  initial,
  loading,
  loaded,
  notFound,
  failure,
}

class ReportDetailsState extends Equatable {
  final ReportDetailsStatus status;

  final Report? report;
  final List<Upvote> upvotes;

  final bool isUpvoting;
  final bool hasUpvoted;

  final String? errorMessage;

  const ReportDetailsState({
    this.status = ReportDetailsStatus.initial,
    this.report,
    this.upvotes = const [],
    this.isUpvoting = false,
    this.hasUpvoted = false,
    this.errorMessage,
  });

  ReportDetailsState copyWith({
    ReportDetailsStatus? status,
    Report? report,
    List<Upvote>? upvotes,
    bool? isUpvoting,
    bool? hasUpvoted,
    String? errorMessage,
    bool clearError = false,
  }) {
    return ReportDetailsState(
      status: status ?? this.status,
      report: report ?? this.report,
      upvotes: upvotes ?? this.upvotes,
      isUpvoting: isUpvoting ?? this.isUpvoting,
      hasUpvoted: hasUpvoted ?? this.hasUpvoted,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
        status,
        report,
        upvotes,
        isUpvoting,
        hasUpvoted,
        errorMessage,
      ];
}
