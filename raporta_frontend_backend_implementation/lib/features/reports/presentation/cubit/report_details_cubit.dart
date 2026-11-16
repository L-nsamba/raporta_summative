import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/upvotes.dart';

import '../../domain/usecases/get_report_by_id.dart';
import '../../domain/usecases/get_upvote.dart';
import '../../domain/usecases/toggle_upvote.dart';

import 'report_details_state.dart';

class ReportDetailsCubit extends Cubit<ReportDetailsState> {
  final GetReportById getReportById;
  final GetUpvotes getUpvotes;
  final ToggleUpvote toggleUpvote;

  ReportDetailsCubit({
    required this.getReportById,
    required this.getUpvotes,
    required this.toggleUpvote,
  }) : super(const ReportDetailsState());

  // LOAD REPORT DETAILS
  Future<void> loadReportDetails({
    required String reportId,
    required String userId,
  }) async {
    if (isClosed) return;

    emit(state.copyWith(status: ReportDetailsStatus.loading, clearError: true));

    try {
      final report = await getReportById(reportId);

      if (isClosed) return;

      if (report == null || report.deletedAt != null) {
        emit(const ReportDetailsState(status: ReportDetailsStatus.notFound));
        return;
      }

      // Upvotes are only accessible on public reports.
      final upvotes = report.status.isPublic
          ? await getUpvotes(reportId)
          : <Upvote>[];

      if (isClosed) return;

      final hasUpvoted = upvotes.any((upvote) => upvote.userId == userId);

      emit(
        state.copyWith(
          status: ReportDetailsStatus.loaded,
          report: report,
          upvotes: upvotes,
          hasUpvoted: hasUpvoted,
          clearError: true,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      emit(
        state.copyWith(
          status: ReportDetailsStatus.failure,
          errorMessage: 'Unable to load report details. Please try again.',
        ),
      );
    }
  }

  // TOGGLE UPVOTE

  Future<void> toggleReportUpvote({required String userId}) async {
    final report = state.report;

    if (report == null ||
        !report.status.isPublic ||
        state.status != ReportDetailsStatus.loaded ||
        state.isUpvoting) {
      return;
    }

    emit(state.copyWith(isUpvoting: true, clearError: true));

    try {
      await toggleUpvote(reportId: report.reportId, userId: userId);

      final updatedUpvotes = await getUpvotes(report.reportId);

      final hasUpvoted = updatedUpvotes.any(
        (upvote) => upvote.userId == userId,
      );

      emit(
        state.copyWith(
          upvotes: updatedUpvotes,
          hasUpvoted: hasUpvoted,
          isUpvoting: false,
          clearError: true,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          isUpvoting: false,
          errorMessage: 'Unable to update your upvote. Please try again.',
        ),
      );
    }
  }

  // REFRESH REPORT DETAILS

  Future<void> refreshReportDetails({
    required String reportId,
    required String userId,
  }) async {
    await loadReportDetails(reportId: reportId, userId: userId);
  }

  // RESET STATE

  void resetDetails() {
    emit(const ReportDetailsState());
  }
}
