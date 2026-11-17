import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:raporta_frontend_backend_implementation/core/enums/report_category.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/repositories/reports_repository.dart';
import 'package:raporta_frontend_backend_implementation/features/dashboard/domain/usecases/get_official_dashboard.dart';

class MockReportsRepository extends Mock implements ReportsRepository {}

void main() {
  late MockReportsRepository repository;
  late GetOfficialDashboard usecase;

  // Thursday, November 12, 2026.
  final now = DateTime(2026, 11, 12, 12);

  Report createReport({
    required String id,
    ReportStatus status = ReportStatus.pending,
    String areaId = 'area-1',
    DateTime? createdAt,
  }) {
    final date = createdAt ?? now;

    return Report(
      reportId: id,
      userId: 'citizen-123',
      areaId: areaId,
      category: ReportCategory.values.first,
      description: 'Test report $id',
      lat: -1.9441,
      lng: 30.0619,
      locationDescription: 'Test location',
      status: status,
      createdAt: date,
      updatedAt: date,
    );
  }

  setUp(() {
    repository = MockReportsRepository();
    usecase = GetOfficialDashboard(repository);

    when(() => repository.getReports()).thenAnswer((_) async => []);
  });

  test('returns correct report status counts', () async {
    final reports = [
      createReport(id: 'report-1', status: ReportStatus.pending),
      createReport(
        id: 'report-2',
        status: ReportStatus.pending,
        areaId: 'area-2',
      ),
      createReport(id: 'report-3', status: ReportStatus.underReview),
      createReport(id: 'report-4', status: ReportStatus.forwarded),
      createReport(id: 'report-5', status: ReportStatus.resolved),
      createReport(id: 'report-6', status: ReportStatus.inProgress),
      createReport(id: 'report-7', status: ReportStatus.declined),
    ];

    when(() => repository.getReports()).thenAnswer((_) async => reports);

    final result = await usecase(now: now);

    expect(result.pendingReports, 2);
    expect(result.underReviewReports, 1);
    expect(result.forwardedReports, 1);
    expect(result.resolvedReports, 1);
  });

  test('generates seven daily counts from Monday to Sunday', () async {
    final result = await usecase(now: now);

    expect(result.weeklyReports.length, 7);

    expect(result.weeklyReports.first.date, DateTime(2026, 11, 9));

    expect(result.weeklyReports.last.date, DateTime(2026, 11, 15));

    expect(result.weeklyReports.first.date.weekday, DateTime.monday);

    expect(result.weeklyReports.last.date.weekday, DateTime.sunday);
  });

  test('counts reports submitted on the correct day', () async {
    final reports = [
      createReport(id: 'report-1', createdAt: DateTime(2026, 11, 9, 8)),
      createReport(id: 'report-2', createdAt: DateTime(2026, 11, 9, 16)),
      createReport(id: 'report-3', createdAt: DateTime(2026, 11, 11, 10)),
      createReport(id: 'report-4', createdAt: DateTime(2026, 11, 12, 9)),
    ];

    when(() => repository.getReports()).thenAnswer((_) async => reports);

    final result = await usecase(now: now);

    expect(result.weeklyReports.map((day) => day.count), [2, 0, 1, 1, 0, 0, 0]);
  });

  test('excludes reports outside the current calendar week', () async {
    final reports = [
      createReport(
        id: 'previous-week',
        createdAt: DateTime(2026, 11, 8, 23, 59),
      ),
      createReport(id: 'current-week', createdAt: DateTime(2026, 11, 9)),
      createReport(id: 'next-week', createdAt: DateTime(2026, 11, 16)),
    ];

    when(() => repository.getReports()).thenAnswer((_) async => reports);

    final result = await usecase(now: now);

    expect(result.weeklyReports.map((day) => day.count), [1, 0, 0, 0, 0, 0, 0]);
  });

  test('handles a calendar week spanning two months', () async {
    final reports = [
      createReport(id: 'october-report', createdAt: DateTime(2026, 10, 31, 12)),
      createReport(id: 'november-report', createdAt: DateTime(2026, 11, 1, 10)),
    ];

    when(() => repository.getReports()).thenAnswer((_) async => reports);

    final result = await usecase(now: DateTime(2026, 11, 1, 12));

    expect(result.weeklyReports.first.date, DateTime(2026, 10, 26));

    expect(result.weeklyReports.last.date, DateTime(2026, 11, 1));

    expect(result.weeklyReports.map((day) => day.count), [0, 0, 0, 0, 0, 1, 1]);
  });

  test('returns the five latest reports in descending order', () async {
    final reports = List.generate(
      7,
      (index) => createReport(
        id: 'report-$index',
        createdAt: DateTime(2026, 11, index + 1),
      ),
    );

    when(() => repository.getReports()).thenAnswer((_) async => reports);

    final result = await usecase(now: now);

    expect(result.latestReports.length, 5);

    expect(result.latestReports.map((report) => report.reportId), [
      'report-6',
      'report-5',
      'report-4',
      'report-3',
      'report-2',
    ]);
  });

  test('returns zero statistics and seven empty days', () async {
    final result = await usecase(now: now);

    expect(result.pendingReports, 0);
    expect(result.underReviewReports, 0);
    expect(result.forwardedReports, 0);
    expect(result.resolvedReports, 0);

    expect(result.latestReports, isEmpty);
    expect(result.weeklyReports.length, 7);

    expect(result.weeklyReports.every((day) => day.count == 0), isTrue);
  });

  test('propagates repository failures', () async {
    when(() => repository.getReports())
        .thenThrow(Exception('Unable to retrieve reports'));

    await expectLater(usecase(now: now), throwsA(isA<Exception>()));
  });
}