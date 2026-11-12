import 'package:flutter_test/flutter_test.dart';

import 'package:raporta_frontend_backend_implementation/core/enums/decline_reason.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';
import 'package:raporta_frontend_backend_implementation/features/moderation/presentation/cubit/moderation_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/moderation/presentation/cubit/moderation_state.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/repositories/reports_repository.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/decline_report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/forward_report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/update_report_status.dart';

class FakeReportsRepository extends Fake implements ReportsRepository {
  String? lastReportId;
  String? lastAgencyId;
  ReportStatus? lastStatus;
  DeclineReason? lastReason;
  String? lastFeedback;

  bool shouldFail = false;

  void checkFailure() {
    if (shouldFail) {
      throw Exception('Moderation failed');
    }
  }

  @override
  Future<void> updateReportStatus({
    required String reportId,
    required ReportStatus status,
  }) async {
    checkFailure();
    lastReportId = reportId;
    lastStatus = status;
  }

  @override
  Future<void> forwardReport({
    required String reportId,
    required String agencyId,
  }) async {
    checkFailure();
    lastReportId = reportId;
    lastAgencyId = agencyId;
  }

  @override
  Future<void> declineReport({
    required String reportId,
    required DeclineReason reason,
    String? feedback,
  }) async {
    checkFailure();
    lastReportId = reportId;
    lastReason = reason;
    lastFeedback = feedback;
  }
}

void main() {
  late FakeReportsRepository repository;
  late ModerationCubit cubit;

  setUp(() {
    repository = FakeReportsRepository();

    cubit = ModerationCubit(
      updateReportStatus: UpdateReportStatus(repository: repository),
      forwardReport: ForwardReport(repository: repository),
      declineReport: DeclineReport(repository: repository),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  test('initial state is correct', () {
    expect(cubit.state.status, ModerationStatus.initial);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.successMessage, isNull);
  });

  test('updates report status successfully', () async {
    final expectation = expectLater(
      cubit.stream,
      emitsInOrder([
        isA<ModerationState>().having(
          (state) => state.status,
          'status',
          ModerationStatus.submitting,
        ),
        isA<ModerationState>().having(
          (state) => state.status,
          'status',
          ModerationStatus.success,
        ),
      ]),
    );

    await cubit.updateStatus(
      reportId: 'report_1',
      status: ReportStatus.underReview,
    );

    await expectation;

    expect(repository.lastReportId, 'report_1');
    expect(repository.lastStatus, ReportStatus.underReview);
  });

  test('forwards report to selected agency', () async {
    await cubit.forward(reportId: 'report_1', agencyId: 'roads_office');

    expect(repository.lastReportId, 'report_1');
    expect(repository.lastAgencyId, 'roads_office');
    expect(cubit.state.status, ModerationStatus.success);
  });

  test('declines report with reason and feedback', () async {
    await cubit.decline(
      reportId: 'report_1',
      reason: DeclineReason.duplicate,
      feedback: 'Already reported.',
    );

    expect(repository.lastReportId, 'report_1');
    expect(repository.lastReason, DeclineReason.duplicate);
    expect(repository.lastFeedback, 'Already reported.');
    expect(cubit.state.status, ModerationStatus.success);
  });

  test('handles moderation failures', () async {
    repository.shouldFail = true;

    await cubit.forward(reportId: 'report_1', agencyId: 'roads_office');

    expect(cubit.state.status, ModerationStatus.failure);
    expect(cubit.state.errorMessage, contains('Moderation failed'));
  });

  test('reset returns to initial state', () async {
    await cubit.updateStatus(
      reportId: 'report_1',
      status: ReportStatus.underReview,
    );

    cubit.reset();

    expect(cubit.state.status, ModerationStatus.initial);
    expect(cubit.state.errorMessage, isNull);
    expect(cubit.state.successMessage, isNull);
  });
}
