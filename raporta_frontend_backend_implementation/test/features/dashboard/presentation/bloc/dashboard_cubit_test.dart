import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:raporta_frontend_backend_implementation/features/dashboard/domain/entities/citizen_dashboard_stats.dart';
import 'package:raporta_frontend_backend_implementation/features/dashboard/domain/entities/official_dashboard_stats.dart';
import 'package:raporta_frontend_backend_implementation/features/dashboard/domain/entities/daily_report_count.dart';

import 'package:raporta_frontend_backend_implementation/features/dashboard/domain/usecases/get_citizen_dashboard.dart';
import 'package:raporta_frontend_backend_implementation/features/dashboard/domain/usecases/get_official_dashboard.dart';

import 'package:raporta_frontend_backend_implementation/features/dashboard/presentation/bloc/dashboard_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/dashboard/presentation/bloc/dashboard_state.dart';

class MockGetCitizenDashboard extends Mock implements GetCitizenDashboard {}

class MockGetOfficialDashboard extends Mock implements GetOfficialDashboard {}

void main() {
  late MockGetCitizenDashboard getCitizenDashboard;
  late MockGetOfficialDashboard getOfficialDashboard;

  const userId = 'citizen-123';
  const areaId = 'remera';

  const citizenStats = CitizenDashboardStats(
    totalReportsInArea: 10,
    resolvedReportsInArea: 3,
    activeReportsInArea: 6,
    myReports: 2,
    latestReports: [],
  );

  final officialStats = OfficialDashboardStats(
    pendingReports: 5,
    underReviewReports: 3,
    forwardedReports: 2,
    resolvedReports: 4,
    weeklyReports: List.generate(
      7,
      (index) =>
          DailyReportCount(date: DateTime(2026, 11, 9 + index), count: index),
    ),
    latestReports: [],
  );

  DashboardCubit buildCubit() {
    return DashboardCubit(
      getCitizenDashboard: getCitizenDashboard,
      getOfficialDashboard: getOfficialDashboard,
    );
  }

  setUp(() {
    getCitizenDashboard = MockGetCitizenDashboard();
    getOfficialDashboard = MockGetOfficialDashboard();
  });

  group('DashboardCubit', () {
    test('initial state is correct', () async {
      final cubit = buildCubit();

      expect(cubit.state.status, DashboardStatus.initial);
      expect(cubit.state.citizenStats, isNull);
      expect(cubit.state.officialStats, isNull);
      expect(cubit.state.errorMessage, isNull);

      await cubit.close();
    });

    blocTest<DashboardCubit, DashboardState>(
      'loads citizen dashboard successfully',
      build: () {
        when(() => getCitizenDashboard(userId: userId, areaId: areaId))
            .thenAnswer((_) async => citizenStats);

        return buildCubit();
      },
      act: (cubit) =>
          cubit.loadCitizenDashboard(userId: userId, areaId: areaId),
      expect: () => [
        isA<DashboardState>().having(
          (state) => state.status,
          'status',
          DashboardStatus.loading,
        ),
        isA<DashboardState>()
            .having((state) => state.status, 'status', DashboardStatus.loaded)
            .having((state) => state.citizenStats, 'citizenStats', citizenStats)
            .having((state) => state.officialStats, 'officialStats', isNull),
      ],
      verify: (_) {
        verify(() => getCitizenDashboard(userId: userId, areaId: areaId))
            .called(1);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits failure when citizen dashboard loading fails',
      build: () {
        when(() => getCitizenDashboard(userId: userId, areaId: areaId))
            .thenThrow(Exception('Failed to load reports'));

        return buildCubit();
      },
      act: (cubit) =>
          cubit.loadCitizenDashboard(userId: userId, areaId: areaId),
      expect: () => [
        isA<DashboardState>().having(
          (state) => state.status,
          'status',
          DashboardStatus.loading,
        ),
        isA<DashboardState>()
            .having((state) => state.status, 'status', DashboardStatus.failure)
            .having((state) => state.errorMessage, 'errorMessage', isNotEmpty),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'loads official dashboard successfully',
      build: () {
        when(() => getOfficialDashboard())
            .thenAnswer((_) async => officialStats);

        return buildCubit();
      },
      act: (cubit) => cubit.loadOfficialDashboard(),
      expect: () => [
        isA<DashboardState>().having(
          (state) => state.status,
          'status',
          DashboardStatus.loading,
        ),
        isA<DashboardState>()
            .having((state) => state.status, 'status', DashboardStatus.loaded)
            .having(
              (state) => state.officialStats,
              'officialStats',
              officialStats,
            )
            .having((state) => state.citizenStats, 'citizenStats', isNull),
      ],
      verify: (_) {
        verify(() => getOfficialDashboard()).called(1);
      },
    );

    blocTest<DashboardCubit, DashboardState>(
      'emits failure when official dashboard loading fails',
      build: () {
        when(() => getOfficialDashboard())
            .thenThrow(Exception('Failed to load reports'));

        return buildCubit();
      },
      act: (cubit) => cubit.loadOfficialDashboard(),
      expect: () => [
        isA<DashboardState>().having(
          (state) => state.status,
          'status',
          DashboardStatus.loading,
        ),
        isA<DashboardState>()
            .having((state) => state.status, 'status', DashboardStatus.failure)
            .having((state) => state.errorMessage, 'errorMessage', isNotEmpty),
      ],
    );

    blocTest<DashboardCubit, DashboardState>(
      'resets dashboard to its initial state',
      build: () {
        when(() => getOfficialDashboard())
            .thenAnswer((_) async => officialStats);

        return buildCubit();
      },
      act: (cubit) async {
        await cubit.loadOfficialDashboard();
        cubit.reset();
      },
      expect: () => [
        isA<DashboardState>().having(
          (state) => state.status,
          'status',
          DashboardStatus.loading,
        ),
        isA<DashboardState>().having(
          (state) => state.status,
          'status',
          DashboardStatus.loaded,
        ),
        isA<DashboardState>()
            .having((state) => state.status, 'status', DashboardStatus.initial)
            .having((state) => state.citizenStats, 'citizenStats', isNull)
            .having((state) => state.officialStats, 'officialStats', isNull)
            .having((state) => state.errorMessage, 'errorMessage', isNull),
      ],
    );

    test(
      'ignores an old citizen request after official dashboard loads',
      () async {
        final completer = Completer<CitizenDashboardStats>();

        when(() => getCitizenDashboard(userId: userId, areaId: areaId))
            .thenAnswer((_) => completer.future);

        when(() => getOfficialDashboard())
            .thenAnswer((_) async => officialStats);

        final cubit = buildCubit();

        final citizenRequest = cubit.loadCitizenDashboard(
          userId: userId,
          areaId: areaId,
        );

        await cubit.loadOfficialDashboard();

        // The older citizen request finishes later.
        completer.complete(citizenStats);
        await citizenRequest;

        expect(cubit.state.status, DashboardStatus.loaded);
        expect(cubit.state.officialStats, officialStats);
        expect(cubit.state.citizenStats, isNull);

        await cubit.close();
      },
    );

    test('ignores an outstanding request after reset', () async {
      final completer = Completer<OfficialDashboardStats>();

      when(() => getOfficialDashboard()).thenAnswer((_) => completer.future);

      final cubit = buildCubit();

      final request = cubit.loadOfficialDashboard();

      cubit.reset();

      // The request finishes after the dashboard was reset.
      completer.complete(officialStats);
      await request;

      expect(cubit.state.status, DashboardStatus.initial);
      expect(cubit.state.officialStats, isNull);

      await cubit.close();
    });

    test('can retry successfully after a failure', () async {
      when(() => getOfficialDashboard()).thenThrow(Exception('Network error'));

      final cubit = buildCubit();

      await cubit.loadOfficialDashboard();

      expect(cubit.state.status, DashboardStatus.failure);
      expect(cubit.state.errorMessage, isNotNull);

      when(() => getOfficialDashboard()).thenAnswer((_) async => officialStats);

      await cubit.loadOfficialDashboard();

      expect(cubit.state.status, DashboardStatus.loaded);
      expect(cubit.state.officialStats, officialStats);
      expect(cubit.state.errorMessage, isNull);

      await cubit.close();
    });

    test('does not emit after the cubit has been closed', () async {
      final completer = Completer<OfficialDashboardStats>();

      when(() => getOfficialDashboard()).thenAnswer((_) => completer.future);

      final cubit = buildCubit();

      final request = cubit.loadOfficialDashboard();

      await cubit.close();

      completer.complete(officialStats);

      await expectLater(request, completes);
    });
  });
}
