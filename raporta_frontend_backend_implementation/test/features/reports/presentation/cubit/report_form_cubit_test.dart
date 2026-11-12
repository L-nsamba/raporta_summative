import 'package:flutter_test/flutter_test.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_category.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/create_report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/report_form_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/report_form_state.dart';

import '../../fakes/fake_reports_repository.dart';

void main() {
  late ReportFormCubit cubit;
  late FakeReportsRepository fakeRepository;

  setUp(() {
    fakeRepository = FakeReportsRepository();

    cubit = ReportFormCubit(
      createReport: CreateReport(repository: fakeRepository),
    );
  });

  tearDown(() {
    cubit.close();
  });

  test('initial state is correct', () {
    expect(cubit.state.currentStep, 0);
    expect(cubit.state.category, null);
    expect(cubit.state.description, '');
    expect(cubit.state.photoUrl, null);
    expect(cubit.state.submissionStatus, FormSubmissionStatus.initial);
  });

  test('updates selected category', () {
    cubit.updateCategory(ReportCategory.roads);

    expect(cubit.state.category, ReportCategory.roads);
  });

  test('updates report description', () {
    cubit.updateDescription('Damaged road near the library');

    expect(cubit.state.description, 'Damaged road near the library');
  });

  test('removes optional photo URL', () {
    cubit.updatePhotoUrl('https://example.com/photo.jpg');
    cubit.removePhoto();

    expect(cubit.state.photoUrl, null);
  });

  test('updates selected location', () {
    cubit.updateLocation(
      lat: -1.9441,
      lng: 30.0619,
      locationDescription: 'Near the main library',
    );

    expect(cubit.state.lat, -1.9441);
    expect(cubit.state.lng, 30.0619);
    expect(cubit.state.locationDescription, 'Near the main library');
  });

  test('moves to next step when current step is valid', () {
    cubit.updateCategory(ReportCategory.roads);
    cubit.updateDescription('Damaged road near the library');

    cubit.nextStep();

    expect(cubit.state.currentStep, 1);
    expect(cubit.state.errorMessage, null);
  });

  test('does not move forward when current step is invalid', () {
    cubit.nextStep();

    expect(cubit.state.currentStep, 0);
    expect(cubit.state.errorMessage, isNotNull);
  });

  test('moves backwards while preserving draft information', () {
    cubit.updateCategory(ReportCategory.roads);
    cubit.updateDescription('Damaged road near the library');
    cubit.nextStep();

    cubit.updateLocation(
      lat: -1.9441,
      lng: 30.0619,
      locationDescription: 'Near the main library',
    );

    cubit.nextStep();
    cubit.previousStep();

    expect(cubit.state.currentStep, 1);
    expect(cubit.state.category, ReportCategory.roads);
    expect(cubit.state.description, 'Damaged road near the library');
    expect(cubit.state.lat, -1.9441);
  });

  test('resets selected location', () {
    cubit.updateLocation(
      lat: -1.9441,
      lng: 30.0619,
      locationDescription: 'Near the main library',
    );

    cubit.clearSelectedLocation();

    expect(cubit.state.lat, null);
    expect(cubit.state.lng, null);
    expect(cubit.state.locationDescription, '');
  });

  test('does not submit an incomplete report', () async {
    await cubit.submitReport(userId: 'user_123', areaId: 'kimironko');

    expect(cubit.state.submissionStatus, FormSubmissionStatus.initial);
    expect(cubit.state.errorMessage, isNotNull);
  });

  test('submits report successfully and returns report ID', () async {
    cubit.updateCategory(ReportCategory.roads);
    cubit.updateDescription('Damaged road near the library');

    cubit.nextStep();

    cubit.updateLocation(
      lat: -1.9441,
      lng: 30.0619,
      locationDescription: 'Near the main library',
    );

    cubit.nextStep();

    await cubit.submitReport(userId: 'user_123', areaId: 'kimironko');

    expect(cubit.state.submissionStatus, FormSubmissionStatus.success);

    expect(cubit.state.createdReportId, 'report_123');
  });

  test('emits failure when report submission fails', () async {
    fakeRepository.shouldThrowError = true;

    cubit.updateCategory(ReportCategory.roads);
    cubit.updateDescription('Damaged road near the library');

    cubit.nextStep();

    cubit.updateLocation(
      lat: -1.9441,
      lng: 30.0619,
      locationDescription: 'Near the main library',
    );

    cubit.nextStep();

    await cubit.submitReport(userId: 'user_123', areaId: 'kimironko');

    expect(cubit.state.submissionStatus, FormSubmissionStatus.failure);

    expect(cubit.state.errorMessage, isNotNull);
  });

  test('resets the form to its initial state', () {
    cubit.updateCategory(ReportCategory.roads);
    cubit.updateDescription('Damaged road near the library');

    cubit.resetForm();

    expect(cubit.state.currentStep, 0);
    expect(cubit.state.category, null);
    expect(cubit.state.description, '');
    expect(cubit.state.photoUrl, null);
    expect(cubit.state.lat, null);
    expect(cubit.state.lng, null);
    expect(cubit.state.submissionStatus, FormSubmissionStatus.initial);
  });
}
