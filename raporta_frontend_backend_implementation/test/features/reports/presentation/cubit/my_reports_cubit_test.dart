import 'package:flutter_test/flutter_test.dart';

import 'package:raporta_frontend_backend_implementation/core/enums/report_category.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/get_my_reports.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/my_reports_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/my_reports_state.dart';

import '../../fakes/fake_reports_repository.dart';

void main() {
  late MyReportsCubit cubit;
  late FakeReportsRepository fakeRepository;

  const userId = 'user_123';

  final sampleReport = Report(
    reportId: 'report_123',
    userId: userId,
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

    cubit = MyReportsCubit(
      getMyReports: GetMyReports(repository: fakeRepository),
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is correct', () {
    expect(cubit.state.status, MyReportsStatus.initial);
    expect(cubit.state.reports, isEmpty);
    expect(cubit.state.errorMessage, null);
  });

  test('loads reports successfully', () async {
    fakeRepository.myReports = [sampleReport];

    await cubit.loadMyReports(userId);

    expect(cubit.state.status, MyReportsStatus.loaded);
    expect(cubit.state.reports, [sampleReport]);
    expect(cubit.state.errorMessage, null);
  });

  test('emits empty state when no reports exist', () async {
    fakeRepository.myReports = [];

    await cubit.loadMyReports(userId);

    expect(cubit.state.status, MyReportsStatus.empty);
    expect(cubit.state.reports, isEmpty);
  });

  test('emits failure when retrieval fails', () async {
    fakeRepository.shouldThrowGetMyReportsError = true;

    await cubit.loadMyReports(userId);

    expect(cubit.state.status, MyReportsStatus.failure);
    expect(cubit.state.errorMessage, isNotNull);
  });

  test('refreshes reports successfully', () async {
    fakeRepository.myReports = [sampleReport];

    await cubit.refreshReports(userId);

    expect(cubit.state.status, MyReportsStatus.loaded);
    expect(cubit.state.reports, [sampleReport]);
    expect(fakeRepository.getMyReportsCallCount, 1);
  });

  test('clears reports and resets state', () async {
    fakeRepository.myReports = [sampleReport];

    await cubit.loadMyReports(userId);

    cubit.clearReports();

    expect(cubit.state.status, MyReportsStatus.initial);
    expect(cubit.state.reports, isEmpty);
    expect(cubit.state.errorMessage, null);
  });

  test('uses the supplied user ID when retrieving reports', () async {
    await cubit.loadMyReports(userId);

    expect(fakeRepository.getMyReportsCallCount, 1);
  });
}
