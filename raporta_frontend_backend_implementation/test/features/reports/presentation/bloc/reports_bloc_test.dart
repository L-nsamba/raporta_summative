import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:raporta_frontend_backend_implementation/core/enums/report_category.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';

import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/get_reports.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/get_public_reports.dart';

import 'package:raporta_frontend_backend_implementation/features/reports/presentation/bloc/reports_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/bloc/reports_event.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/bloc/reports_state.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/bloc/reports_scope.dart';

class MockGetReports extends Mock implements GetReports {}

class MockGetPublicReports extends Mock implements GetPublicReports {}

Report makeReport({
  required String id,
  required ReportStatus status,
  String areaId = 'remera',
  String userId = 'citizen-123',
  ReportCategory category = ReportCategory.roads,
  String description = 'Damaged road near campus',
  String locationDescription = 'Near the main road',
}) {
  return Report(
    reportId: id,
    userId: userId,
    areaId: areaId,
    category: category,
    description: description,
    lat: -1.95,
    lng: 30.12,
    locationDescription: locationDescription,
    photoUrl: null,
    status: status,
    declineReason: null,
    declineFeedback: null,
    agencyId: null,
    createdAt: DateTime(2026, 11, 13),
    updatedAt: DateTime(2026, 11, 13),
    deletedAt: null,
  );
}

void main() {
  late MockGetReports getReports;
  late MockGetPublicReports getPublicReports;

  late Report pendingReport;
  late Report underReviewReport;
  late Report forwardedReport;
  late Report inProgressReport;
  late Report resolvedReport;
  late Report declinedReport;

  late List<Report> allReports;
  late List<Report> publicReports;

  ReportsBloc buildBloc(ReportsScope scope) {
    return ReportsBloc(
      getReports: getReports,
      getPublicReports: getPublicReports,
      scope: scope,
    );
  }

  setUp(() {
    getReports = MockGetReports();
    getPublicReports = MockGetPublicReports();

    pendingReport = makeReport(id: 'pending-1', status: ReportStatus.pending);

    underReviewReport = makeReport(
      id: 'review-1',
      status: ReportStatus.underReview,
      description: 'Damaged road in Remera',
    );

    forwardedReport = makeReport(
      id: 'forwarded-1',
      status: ReportStatus.forwarded,
      areaId: 'kimironko',
      description: 'Potholes in Kimironko',
    );

    inProgressReport = makeReport(
      id: 'progress-1',
      status: ReportStatus.inProgress,
      description: 'Road repairs underway',
    );

    resolvedReport = makeReport(
      id: 'resolved-1',
      status: ReportStatus.resolved,
      areaId: 'kimironko',
      description: 'Road repaired',
    );

    declinedReport = makeReport(
      id: 'declined-1',
      status: ReportStatus.declined,
    );

    allReports = [
      pendingReport,
      underReviewReport,
      forwardedReport,
      inProgressReport,
      resolvedReport,
      declinedReport,
    ];

    publicReports = [
      underReviewReport,
      forwardedReport,
      inProgressReport,
      resolvedReport,
    ];

    when(() => getReports()).thenAnswer((_) async => allReports);

    when(() => getPublicReports()).thenAnswer((_) async => publicReports);
  });

  group('ReportsBloc scopes', () {
    test('initial state is correct', () async {
      final bloc = buildBloc(ReportsScope.public);

      expect(bloc.state, const ReportsState());

      await bloc.close();
    });

    blocTest<ReportsBloc, ReportsState>(
      'citizen loads public reports only',
      build: () => buildBloc(ReportsScope.public),
      act: (bloc) => bloc.add(const LoadReports()),
      expect: () => [
        const ReportsState(status: ReportsStatus.loading),
        ReportsState(
          status: ReportsStatus.loaded,
          allReports: publicReports,
          reports: publicReports,
        ),
      ],
      verify: (_) {
        verify(() => getPublicReports()).called(1);
        verifyNever(() => getReports());
      },
    );

    blocTest<ReportsBloc, ReportsState>(
      'official can load all non-deleted reports',
      build: () => buildBloc(ReportsScope.all),
      act: (bloc) => bloc.add(const LoadReports()),
      expect: () => [
        const ReportsState(status: ReportsStatus.loading),
        ReportsState(
          status: ReportsStatus.loaded,
          allReports: allReports,
          reports: allReports,
        ),
      ],
      verify: (_) {
        verify(() => getReports()).called(1);
        verifyNever(() => getPublicReports());
      },
    );

    blocTest<ReportsBloc, ReportsState>(
      'report queue contains only pending reports',
      build: () => buildBloc(ReportsScope.pending),
      act: (bloc) => bloc.add(const LoadReports()),
      expect: () => [
        const ReportsState(status: ReportsStatus.loading),
        ReportsState(
          status: ReportsStatus.loaded,
          allReports: [pendingReport],
          reports: [pendingReport],
        ),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'manage reports contains only approved reports',
      build: () => buildBloc(ReportsScope.approved),
      act: (bloc) => bloc.add(const LoadReports()),
      expect: () => [
        const ReportsState(status: ReportsStatus.loading),
        ReportsState(
          status: ReportsStatus.loaded,
          allReports: publicReports,
          reports: publicReports,
        ),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'emits empty when there are no public reports',
      build: () {
        when(() => getPublicReports()).thenAnswer((_) async => []);

        return buildBloc(ReportsScope.public);
      },
      act: (bloc) => bloc.add(const LoadReports()),
      expect: () => [
        const ReportsState(status: ReportsStatus.loading),
        const ReportsState(status: ReportsStatus.empty),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'emits failure when fetching reports fails',
      build: () {
        when(() => getPublicReports()).thenThrow(Exception('Network error'));

        return buildBloc(ReportsScope.public);
      },
      act: (bloc) => bloc.add(const LoadReports()),
      expect: () => [
        const ReportsState(status: ReportsStatus.loading),
        const ReportsState(
          status: ReportsStatus.failure,
          errorMessage: 'Unable to load reports. Please try again.',
        ),
      ],
    );
  });

  group('ReportsBloc filtering', () {
    ReportsState loadedState() {
      return ReportsState(
        status: ReportsStatus.loaded,
        allReports: publicReports,
        reports: publicReports,
      );
    }

    blocTest<ReportsBloc, ReportsState>(
      'filters reports by Remera',
      build: () => buildBloc(ReportsScope.approved),
      seed: loadedState,
      act: (bloc) => bloc.add(const FilterReports(areaId: 'remera')),
      expect: () => [
        loadedState().copyWith(
          selectedAreaId: 'remera',
          reports: [underReviewReport, inProgressReport],
        ),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'filters reports by Kimironko',
      build: () => buildBloc(ReportsScope.approved),
      seed: loadedState,
      act: (bloc) => bloc.add(const FilterReports(areaId: 'kimironko')),
      expect: () => [
        loadedState().copyWith(
          selectedAreaId: 'kimironko',
          reports: [forwardedReport, resolvedReport],
        ),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'combines area and status filters',
      build: () => buildBloc(ReportsScope.approved),
      seed: loadedState,
      act: (bloc) => bloc.add(
        const FilterReports(
          areaId: 'kimironko',
          status: ReportStatus.forwarded,
        ),
      ),
      expect: () => [
        loadedState().copyWith(
          selectedAreaId: 'kimironko',
          selectedStatus: ReportStatus.forwarded,
          reports: [forwardedReport],
        ),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'combines area, category, status and search',
      build: () => buildBloc(ReportsScope.approved),
      seed: () => loadedState().copyWith(
        selectedAreaId: 'remera',
        selectedCategory: ReportCategory.roads,
        selectedStatus: ReportStatus.underReview,
        reports: [underReviewReport],
      ),
      act: (bloc) => bloc.add(const SearchReports('DAMAGED')),
      expect: () => [
        loadedState().copyWith(
          selectedAreaId: 'remera',
          selectedCategory: ReportCategory.roads,
          selectedStatus: ReportStatus.underReview,
          searchQuery: 'DAMAGED',
          reports: [underReviewReport],
        ),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'search returns no reports when nothing matches',
      build: () => buildBloc(ReportsScope.public),
      seed: loadedState,
      act: (bloc) => bloc.add(const SearchReports('nonexistent issue')),
      expect: () => [
        loadedState().copyWith(searchQuery: 'nonexistent issue', reports: []),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'selecting all areas preserves the status filter',
      build: () => buildBloc(ReportsScope.approved),
      seed: () => loadedState().copyWith(
        selectedAreaId: 'kimironko',
        selectedStatus: ReportStatus.forwarded,
        reports: [forwardedReport],
      ),
      act: (bloc) => bloc.add(
        const FilterReports(status: ReportStatus.forwarded, areaId: null),
      ),
      expect: () => [
        loadedState().copyWith(
          selectedStatus: ReportStatus.forwarded,
          reports: [forwardedReport],
        ),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'clearing filters restores all reports in scope',
      build: () => buildBloc(ReportsScope.approved),
      seed: () => loadedState().copyWith(
        selectedAreaId: 'remera',
        selectedStatus: ReportStatus.underReview,
        selectedCategory: ReportCategory.roads,
        searchQuery: 'damaged',
        reports: [underReviewReport],
      ),
      act: (bloc) => bloc.add(const ClearReportFilters()),
      expect: () => [loadedState()],
    );

    blocTest<ReportsBloc, ReportsState>(
      'clearing queue filters does not expose approved reports',
      build: () => buildBloc(ReportsScope.pending),
      seed: () => ReportsState(
        status: ReportsStatus.loaded,
        allReports: [pendingReport],
        reports: [],
        searchQuery: 'nothing matches',
      ),
      act: (bloc) => bloc.add(const ClearReportFilters()),
      expect: () => [
        ReportsState(
          status: ReportsStatus.loaded,
          allReports: [pendingReport],
          reports: [pendingReport],
        ),
      ],
    );
  });

  group('ReportsBloc refresh and moderation', () {
    blocTest<ReportsBloc, ReportsState>(
      'refresh preserves the selected area and status',
      build: () => buildBloc(ReportsScope.approved),
      seed: () => ReportsState(
        status: ReportsStatus.loaded,
        allReports: publicReports,
        reports: [forwardedReport],
        selectedAreaId: 'kimironko',
        selectedStatus: ReportStatus.forwarded,
      ),
      act: (bloc) {
        final newReport = makeReport(
          id: 'forwarded-2',
          status: ReportStatus.forwarded,
          areaId: 'kimironko',
        );

        when(() => getReports())
            .thenAnswer((_) async => [...allReports, newReport]);

        bloc.add(const RefreshReports());
      },
      expect: () => [
        isA<ReportsState>()
            .having((state) => state.status, 'status', ReportsStatus.loaded)
            .having((state) => state.selectedAreaId, 'area', 'kimironko')
            .having(
              (state) => state.selectedStatus,
              'selected status',
              ReportStatus.forwarded,
            )
            .having((state) => state.reports.length, 'matching reports', 2),
      ],
    );

    blocTest<ReportsBloc, ReportsState>(
      'approved report disappears from the pending queue',
      build: () => buildBloc(ReportsScope.pending),
      seed: () => ReportsState(
        status: ReportsStatus.loaded,
        allReports: [pendingReport],
        reports: [pendingReport],
      ),
      act: (bloc) {
        final approvedReport = makeReport(
          id: pendingReport.reportId,
          status: ReportStatus.underReview,
        );

        when(() => getReports()).thenAnswer(
          (_) async => [approvedReport, ...publicReports, declinedReport],
        );

        bloc.add(const RefreshReports());
      },
      expect: () => [const ReportsState(status: ReportsStatus.empty)],
    );

    blocTest<ReportsBloc, ReportsState>(
      'newly approved report appears in manage reports',
      build: () => buildBloc(ReportsScope.approved),
      seed: () => ReportsState(
        status: ReportsStatus.loaded,
        allReports: publicReports,
        reports: publicReports,
      ),
      act: (bloc) {
        final approvedReport = makeReport(
          id: pendingReport.reportId,
          status: ReportStatus.underReview,
        );

        when(() => getReports()).thenAnswer(
          (_) async => [approvedReport, ...publicReports, declinedReport],
        );

        bloc.add(const RefreshReports());
      },
      expect: () => [
        isA<ReportsState>()
            .having((state) => state.status, 'status', ReportsStatus.loaded)
            .having((state) => state.reports.length, 'approved report count', 5)
            .having(
              (state) => state.reports.any(
                (report) =>
                    report.reportId == pendingReport.reportId &&
                    report.status == ReportStatus.underReview,
              ),
              'contains newly approved report',
              true,
            ),
      ],
    );
  });

  test('older request cannot overwrite newer report data', () async {
    final oldRequest = Completer<List<Report>>();
    final newRequest = Completer<List<Report>>();

    final oldStarted = Completer<void>();
    final newStarted = Completer<void>();

    var calls = 0;

    when(() => getPublicReports()).thenAnswer((_) {
      calls++;

      if (calls == 1) {
        oldStarted.complete();
        return oldRequest.future;
      }

      newStarted.complete();
      return newRequest.future;
    });

    final bloc = buildBloc(ReportsScope.public);

    addTearDown(bloc.close);

    // Start the first request.
    bloc.add(const LoadReports());
    await oldStarted.future;

    // Start a newer refresh request.
    bloc.add(const RefreshReports());
    await newStarted.future;

    final latestReports = [underReviewReport, forwardedReport];

    final latestState = bloc.stream.firstWhere(
      (state) => state.status == ReportsStatus.loaded,
    );

    // Newer request finishes first.
    newRequest.complete(latestReports);
    await latestState;

    expect(bloc.state.reports, latestReports);

    // Older request finishes with outdated data.
    oldRequest.complete([underReviewReport]);

    // Closing waits for outstanding event handlers.
    await bloc.close();

    expect(bloc.state.reports, latestReports);
    expect(bloc.state.status, ReportsStatus.loaded);
  });
}
