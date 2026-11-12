import 'package:flutter_test/flutter_test.dart';

import 'package:raporta_frontend_backend_implementation/core/enums/report_category.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/upvotes.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/get_report_by_id.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/get_upvote.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/toggle_upvote.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/report_details_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/report_details_state.dart';

import '../../fakes/fake_reports_repository.dart';

void main() {
  late ReportDetailsCubit cubit;
  late FakeReportsRepository fakeRepository;

  const userId = 'user_123';
  const reportId = 'report_123';

  final sampleReport = Report(
    reportId: reportId,
    userId: 'another_user',
    areaId: 'kimironko',
    category: ReportCategory.roads,
    description: 'Damaged road near the library',
    lat: -1.9441,
    lng: 30.0619,
    locationDescription: 'Near the main library',
    status: ReportStatus.pending,
    createdAt: DateTime(2026, 11, 8),
    updatedAt: DateTime(2026, 11, 8),
  );

  setUp(() {
    fakeRepository = FakeReportsRepository();

    cubit = ReportDetailsCubit(
      getReportById: GetReportById(repository: fakeRepository),
      getUpvotes: GetUpvotes(repository: fakeRepository),
      toggleUpvote: ToggleUpvote(repository: fakeRepository),
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is correct', () {
    expect(cubit.state.status, ReportDetailsStatus.initial);
    expect(cubit.state.report, null);
    expect(cubit.state.upvotes, isEmpty);
    expect(cubit.state.hasUpvoted, false);
  });

  test('loads report details successfully', () async {
    fakeRepository.reportToReturn = sampleReport;

    await cubit.loadReportDetails(reportId: reportId, userId: userId);

    expect(cubit.state.status, ReportDetailsStatus.loaded);
    expect(cubit.state.report, sampleReport);
  });

  test('emits notFound when report does not exist', () async {
    fakeRepository.reportToReturn = null;

    await cubit.loadReportDetails(reportId: reportId, userId: userId);

    expect(cubit.state.status, ReportDetailsStatus.notFound);
  });

  test('emits notFound for a deleted report', () async {
    fakeRepository.reportToReturn = Report(
      reportId: reportId,
      userId: 'another_user',
      areaId: 'kimironko',
      category: ReportCategory.roads,
      description: 'Damaged road',
      lat: -1.9441,
      lng: 30.0619,
      locationDescription: 'Near the library',
      status: ReportStatus.pending,
      createdAt: DateTime(2026, 11, 8),
      updatedAt: DateTime(2026, 11, 8),
      deletedAt: DateTime(2026, 11, 8),
    );

    await cubit.loadReportDetails(reportId: reportId, userId: userId);

    expect(cubit.state.status, ReportDetailsStatus.notFound);
  });

  test('emits failure when report retrieval fails', () async {
    fakeRepository.shouldThrowGetReportError = true;

    await cubit.loadReportDetails(reportId: reportId, userId: userId);

    expect(cubit.state.status, ReportDetailsStatus.failure);
    expect(cubit.state.errorMessage, isNotNull);
  });

  test('loads upvotes and detects current user upvote', () async {
    fakeRepository.reportToReturn = sampleReport;
    fakeRepository.upvotes = [
      Upvote(userId: userId, createdAt: DateTime(2026, 11, 8)),
    ];

    await cubit.loadReportDetails(reportId: reportId, userId: userId);

    expect(cubit.state.upvotes.length, 1);
    expect(cubit.state.hasUpvoted, true);
  });

  test('successfully adds an upvote', () async {
    fakeRepository.reportToReturn = sampleReport;

    await cubit.loadReportDetails(reportId: reportId, userId: userId);

    await cubit.toggleReportUpvote(userId: userId);

    expect(cubit.state.upvotes.length, 1);
    expect(cubit.state.hasUpvoted, true);
    expect(cubit.state.isUpvoting, false);
  });

  test('successfully removes an existing upvote', () async {
    fakeRepository.reportToReturn = sampleReport;
    fakeRepository.upvotes = [
      Upvote(userId: userId, createdAt: DateTime(2026, 11, 8)),
    ];

    await cubit.loadReportDetails(reportId: reportId, userId: userId);

    await cubit.toggleReportUpvote(userId: userId);

    expect(cubit.state.upvotes, isEmpty);
    expect(cubit.state.hasUpvoted, false);
  });

  test('handles failed upvote interaction', () async {
    fakeRepository.reportToReturn = sampleReport;

    await cubit.loadReportDetails(reportId: reportId, userId: userId);

    fakeRepository.shouldThrowToggleUpvoteError = true;

    await cubit.toggleReportUpvote(userId: userId);

    expect(cubit.state.isUpvoting, false);
    expect(cubit.state.errorMessage, isNotNull);
  });

  test('resets report details state', () async {
    fakeRepository.reportToReturn = sampleReport;

    await cubit.loadReportDetails(reportId: reportId, userId: userId);

    cubit.resetDetails();

    expect(cubit.state.status, ReportDetailsStatus.initial);
    expect(cubit.state.report, null);
    expect(cubit.state.upvotes, isEmpty);
  });
}
