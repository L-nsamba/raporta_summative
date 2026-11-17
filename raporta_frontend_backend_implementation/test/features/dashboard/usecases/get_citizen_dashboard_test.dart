import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:raporta_frontend_backend_implementation/core/enums/report_category.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_status.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/entities/report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/repositories/reports_repository.dart';
import 'package:raporta_frontend_backend_implementation/features/dashboard/domain/usecases/get_citizen_dashboard.dart';

class MockReportsRepository extends Mock implements ReportsRepository {}

void main() {
  late MockReportsRepository repository;
  late GetCitizenDashboard usecase;

  const citizenId = 'citizen-123';
  const anotherCitizenId = 'citizen-456';
  const areaOne = 'area-1';
  const areaTwo = 'area-2';

  Report createReport({
    required String id,
    String userId = citizenId,
    String areaId = areaOne,
    ReportStatus status = ReportStatus.underReview,
    DateTime? createdAt,
  }) {
    final date = createdAt ?? DateTime(2026, 11, 12);

    return Report(
      reportId: id,
      userId: userId,
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
    usecase = GetCitizenDashboard(repository);

    when(() => repository.getPublicReports()).thenAnswer((_) async => []);

    when(() => repository.getMyReports(citizenId)).thenAnswer((_) async => []);
  });

  test('returns correct public statistics for the citizens area', () async {
    final reports = [
      createReport(id: 'report-1', status: ReportStatus.pending),
      createReport(
        id: 'report-2',
        userId: anotherCitizenId,
        status: ReportStatus.resolved,
      ),
      createReport(
        id: 'report-3',
        userId: anotherCitizenId,
        status: ReportStatus.inProgress,
      ),
      createReport(
        id: 'report-4',
        areaId: areaTwo,
        status: ReportStatus.resolved,
      ),
    ];

    final publicReports = reports
        .where((report) => report.status.isPublic)
        .toList();

    when(() => repository.getPublicReports())
        .thenAnswer((_) async => publicReports);

    when(() => repository.getMyReports(citizenId))
        .thenAnswer((_) async => [reports[0], reports[3]]);

    final result = await usecase(userId: citizenId, areaId: areaOne);

    expect(result.totalReportsInArea, 2);
    expect(result.resolvedReportsInArea, 1);
    expect(result.activeReportsInArea, 1);
    expect(result.myReports, 2);
    expect(result.latestReports.length, 2);

    verify(() => repository.getPublicReports()).called(1);
    verifyNever(() => repository.getReports());
  });

  test('excludes reports from other areas', () async {
    when(() => repository.getPublicReports()).thenAnswer(
      (_) async => [
        createReport(id: 'report-1'),
        createReport(id: 'report-2', areaId: areaTwo),
      ],
    );

    final result = await usecase(userId: citizenId, areaId: areaOne);

    expect(result.totalReportsInArea, 1);
    expect(result.latestReports.length, 1);
    expect(result.latestReports.first.reportId, 'report-1');
  });

  test('counts only approved active statuses as active', () async {
    final reports = ReportStatus.values
        .map((status) {
          return createReport(id: 'report-${status.name}', status: status);
        })
        .where((report) => report.status.isPublic)
        .toList();

    when(() => repository.getPublicReports()).thenAnswer((_) async => reports);

    final result = await usecase(userId: citizenId, areaId: areaOne);

    expect(result.totalReportsInArea, 4);
    expect(result.activeReportsInArea, 3);
    expect(result.resolvedReportsInArea, 1);
  });

  test('counts personal reports across different areas and statuses', () async {
    final ownReports = [
      createReport(id: 'report-1', status: ReportStatus.underReview),
      createReport(
        id: 'report-2',
        areaId: areaTwo,
        status: ReportStatus.pending,
      ),
      createReport(id: 'report-3', status: ReportStatus.declined),
    ];

    when(() => repository.getPublicReports()).thenAnswer(
      (_) async =>
          ownReports.where((report) => report.status.isPublic).toList(),
    );

    when(() => repository.getMyReports(citizenId))
        .thenAnswer((_) async => ownReports);

    final result = await usecase(userId: citizenId, areaId: areaOne);

    expect(result.totalReportsInArea, 1);
    expect(result.myReports, 3);

    verify(() => repository.getMyReports(citizenId)).called(1);
  });

  test('returns the five latest public reports in descending order', () async {
    final reports = List.generate(
      7,
      (index) => createReport(
        id: 'report-$index',
        status: ReportStatus.underReview,
        createdAt: DateTime(2026, 11, index + 1),
      ),
    );

    when(() => repository.getPublicReports()).thenAnswer((_) async => reports);

    final result = await usecase(userId: citizenId, areaId: areaOne);

    expect(result.latestReports.length, 5);

    expect(result.latestReports.map((report) => report.reportId), [
      'report-6',
      'report-5',
      'report-4',
      'report-3',
      'report-2',
    ]);
  });

  test('returns zero statistics when no reports exist', () async {
    final result = await usecase(userId: citizenId, areaId: areaOne);

    expect(result.totalReportsInArea, 0);
    expect(result.resolvedReportsInArea, 0);
    expect(result.activeReportsInArea, 0);
    expect(result.myReports, 0);
    expect(result.latestReports, isEmpty);
  });

  test('propagates repository failures', () async {
    when(() => repository.getPublicReports())
        .thenThrow(Exception('Unable to retrieve reports'));

    await expectLater(
      usecase(userId: citizenId, areaId: areaOne),
      throwsA(isA<Exception>()),
    );
  });

  test(
    'private personal reports do not contribute to public statistics',
    () async {
      final ownReports = [
        createReport(id: 'pending-1', status: ReportStatus.pending),
        createReport(id: 'declined-1', status: ReportStatus.declined),
      ];

      when(() => repository.getPublicReports()).thenAnswer((_) async => []);

      when(() => repository.getMyReports(citizenId))
          .thenAnswer((_) async => ownReports);

      final result = await usecase(userId: citizenId, areaId: areaOne);

      expect(result.totalReportsInArea, 0);
      expect(result.activeReportsInArea, 0);
      expect(result.resolvedReportsInArea, 0);
      expect(result.myReports, 2);
      expect(result.latestReports, isEmpty);
    },
  );
}
