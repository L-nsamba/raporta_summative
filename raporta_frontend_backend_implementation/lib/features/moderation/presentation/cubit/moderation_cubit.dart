import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/decline_report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/forward_report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/update_report_status.dart';

import '../../../../core/enums/report_status.dart';
import '../../../../core/enums/decline_reason.dart';
import 'moderation_state.dart';

class ModerationCubit extends Cubit<ModerationState> {
  final UpdateReportStatus updateReportStatus;
  final ForwardReport forwardReport;
  final DeclineReport declineReport;

  ModerationCubit({
    required this.updateReportStatus,
    required this.forwardReport,
    required this.declineReport,
  }) : super(const ModerationState());

  Future<void> updateStatus({
    required String reportId,
    required ReportStatus status,
  }) async {
    await _performModeration(
      operation: () => updateReportStatus(reportId: reportId, status: status),
      successMessage: 'Report status updated successfully.',
    );
  }

  Future<void> forward({
    required String reportId,
    required String agencyId,
  }) async {
    await _performModeration(
      operation: () => forwardReport(reportId: reportId, agencyId: agencyId),
      successMessage: 'Report forwarded successfully.',
    );
  }

  Future<void> decline({
    required String reportId,
    required DeclineReason reason,
    String? feedback,
  }) async {
    await _performModeration(
      operation: () =>
          declineReport(reportId: reportId, reason: reason, feedback: feedback),
      successMessage: 'Report declined successfully.',
    );
  }

  Future<void> _performModeration({
    required Future<void> Function() operation,
    required String successMessage,
  }) async {
    if (state.status == ModerationStatus.submitting) return;

    emit(const ModerationState(status: ModerationStatus.submitting));

    try {
      await operation();

      emit(
        ModerationState(
          status: ModerationStatus.success,
          successMessage: successMessage,
        ),
      );
    } catch (e) {
      emit(
        ModerationState(
          status: ModerationStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void reset() {
    emit(const ModerationState());
  }
}
