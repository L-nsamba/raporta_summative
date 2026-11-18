import 'package:flutter_test/flutter_test.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_category.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/create_report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/upload_report_photo.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/report_form_cubit.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/presentation/cubit/report_form_state.dart';

import '../../fakes/fake_report_photo_repository.dart';
import '../../fakes/fake_reports_repository.dart';

import 'dart:async';

void main() {
  late ReportFormCubit cubit;
  late FakeReportsRepository fakeRepository;
  late FakeReportPhotoRepository fakePhotoRepository;

  setUp(() {
    fakeRepository = FakeReportsRepository();
    fakePhotoRepository = FakeReportPhotoRepository();

    cubit = ReportFormCubit(
      createReport: CreateReport(repository: fakeRepository),
      uploadReportPhoto: UploadReportPhoto(repository: fakePhotoRepository),
    );
  });

  tearDown(() async {
    await cubit.close();
  });

  void completeForm() {
    cubit.updateCategory(ReportCategory.roads);

    cubit.updateDescription('Damaged road near the library');

    cubit.nextStep();

    cubit.updateLocation(
      lat: -1.9441,
      lng: 30.0619,
      locationDescription: 'Near the main library',
    );

    cubit.nextStep();
  }

  test('initial state is correct', () {
    expect(cubit.state.currentStep, 0);
    expect(cubit.state.category, null);
    expect(cubit.state.description, '');
    expect(cubit.state.photoUrl, null);
    expect(cubit.state.submissionStatus, FormSubmissionStatus.initial);
    expect(cubit.state.photoPath, isNull);
    expect(cubit.state.hasPhoto, isFalse);
    expect(cubit.state.isBusy, isFalse);
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

    expect(fakeRepository.createReportCallCount, 1);
    expect(fakeRepository.lastCreatedReport!.photoUrl, isNull);
    expect(fakePhotoRepository.uploadPhotoCallCount, 0);
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

    cubit.updatePhotoPath('/test/photo.jpg');
    cubit.resetForm();

    expect(cubit.state.photoPath, isNull);
    expect(cubit.state.hasPhoto, isFalse);
    expect(cubit.state.currentStep, 0);
    expect(cubit.state.category, null);
    expect(cubit.state.description, '');
    expect(cubit.state.photoUrl, null);
    expect(cubit.state.lat, null);
    expect(cubit.state.lng, null);
    expect(cubit.state.submissionStatus, FormSubmissionStatus.initial);
  });

  test('updates selected local photo path', () {
    cubit.updatePhotoPath('/test/photo.jpg');

    expect(cubit.state.photoPath, '/test/photo.jpg');
    expect(cubit.state.photoUrl, isNull);
    expect(cubit.state.hasPhoto, isTrue);
    expect(fakePhotoRepository.uploadPhotoCallCount, 0);
  });

  test('uploads photo and submits report successfully', () async {
    completeForm();

    cubit.updatePhotoPath('/test/photo.jpg');

    await cubit.submitReport(userId: 'user_123', areaId: 'kimironko');

    expect(fakePhotoRepository.uploadPhotoCallCount, 1);

    expect(fakePhotoRepository.lastUploadedFilePath, '/test/photo.jpg');

    expect(
      fakeRepository.lastCreatedReport!.photoUrl,
      fakePhotoRepository.uploadedPhotoUrl,
    );

    expect(fakeRepository.createReportCallCount, 1);

    expect(cubit.state.submissionStatus, FormSubmissionStatus.success);

    expect(cubit.state.createdReportId, 'report_123');
  });

  test('does not create report when photo upload fails', () async {
    fakePhotoRepository.shouldThrowError = true;

    completeForm();

    cubit.updatePhotoPath('/test/photo.jpg');

    await cubit.submitReport(userId: 'user_123', areaId: 'kimironko');

    expect(fakePhotoRepository.uploadPhotoCallCount, 1);
    expect(fakeRepository.createReportCallCount, 0);

    expect(cubit.state.submissionStatus, FormSubmissionStatus.failure);

    expect(
      cubit.state.errorMessage,
      'Failed to upload photo. Please try again.',
    );

    expect(cubit.state.photoPath, '/test/photo.jpg');
    expect(cubit.state.photoUrl, isNull);
  });

  test('retains uploaded photo URL when report creation fails', () async {
    fakeRepository.shouldThrowError = true;

    completeForm();

    cubit.updatePhotoPath('/test/photo.jpg');

    await cubit.submitReport(userId: 'user_123', areaId: 'kimironko');

    expect(fakePhotoRepository.uploadPhotoCallCount, 1);
    expect(fakeRepository.createReportCallCount, 1);

    expect(cubit.state.submissionStatus, FormSubmissionStatus.failure);

    expect(cubit.state.photoUrl, fakePhotoRepository.uploadedPhotoUrl);

    expect(
      cubit.state.errorMessage,
      'Failed to submit report. Please try again.',
    );
  });

  test('retries report creation without uploading photo again', () async {
    fakeRepository.shouldThrowError = true;

    completeForm();

    cubit.updatePhotoPath('/test/photo.jpg');

    await cubit.submitReport(userId: 'user_123', areaId: 'kimironko');

    expect(cubit.state.submissionStatus, FormSubmissionStatus.failure);

    // Simulate Firestore becoming available again.
    fakeRepository.shouldThrowError = false;

    await cubit.submitReport(userId: 'user_123', areaId: 'kimironko');

    expect(fakePhotoRepository.uploadPhotoCallCount, 1);
    expect(fakeRepository.createReportCallCount, 2);

    expect(
      fakeRepository.lastCreatedReport!.photoUrl,
      fakePhotoRepository.uploadedPhotoUrl,
    );

    expect(cubit.state.submissionStatus, FormSubmissionStatus.success);

    expect(cubit.state.createdReportId, 'report_123');
  });

  test('replacing selected photo clears previous uploaded URL', () {
    cubit.updatePhotoUrl('https://example.com/old-photo.jpg');

    cubit.updatePhotoPath('/test/new-photo.jpg');

    expect(cubit.state.photoPath, '/test/new-photo.jpg');
    expect(cubit.state.photoUrl, isNull);
    expect(cubit.state.hasPhoto, isTrue);
  });

  test('removing photo clears local path and uploaded URL', () async {
    fakeRepository.shouldThrowError = true;

    completeForm();

    cubit.updatePhotoPath('/test/photo.jpg');

    // Upload succeeds, but report creation fails.
    await cubit.submitReport(userId: 'user_123', areaId: 'kimironko');

    expect(cubit.state.photoPath, isNotNull);
    expect(cubit.state.photoUrl, isNotNull);

    cubit.removePhoto();

    expect(cubit.state.photoPath, isNull);
    expect(cubit.state.photoUrl, isNull);
    expect(cubit.state.hasPhoto, isFalse);
  });

  test('uploads new photo when replaced after submission failure', () async {
    fakeRepository.shouldThrowError = true;

    completeForm();

    cubit.updatePhotoPath('/test/old-photo.jpg');

    await cubit.submitReport(userId: 'user_123', areaId: 'kimironko');

    expect(fakePhotoRepository.uploadPhotoCallCount, 1);

    cubit.updatePhotoPath('/test/new-photo.jpg');

    expect(cubit.state.photoUrl, isNull);

    fakeRepository.shouldThrowError = false;

    fakePhotoRepository.uploadedPhotoUrl = 'https://example.com/new-photo.jpg';

    await cubit.submitReport(userId: 'user_123', areaId: 'kimironko');

    expect(fakePhotoRepository.uploadPhotoCallCount, 2);

    expect(fakePhotoRepository.lastUploadedFilePath, '/test/new-photo.jpg');

    expect(
      fakeRepository.lastCreatedReport!.photoUrl,
      'https://example.com/new-photo.jpg',
    );

    expect(cubit.state.submissionStatus, FormSubmissionStatus.success);
  });

  test('does not upload photo when report form is incomplete', () async {
    cubit.updateCategory(ReportCategory.roads);
    cubit.updateDescription('Damaged road');
    cubit.updatePhotoPath('/test/photo.jpg');

    // No location has been selected.
    await cubit.submitReport(userId: 'user_123', areaId: 'kimironko');

    expect(fakePhotoRepository.uploadPhotoCallCount, 0);
    expect(fakeRepository.createReportCallCount, 0);

    expect(cubit.state.submissionStatus, FormSubmissionStatus.initial);

    expect(cubit.state.errorMessage, isNotNull);
  });

  test('emits uploading, submitting and success states', () async {
    completeForm();

    cubit.updatePhotoPath('/test/photo.jpg');

    final expectation = expectLater(
      cubit.stream.map((state) => state.submissionStatus),
      emitsInOrder([
        FormSubmissionStatus.uploadingPhoto,
        FormSubmissionStatus.uploadingPhoto,
        FormSubmissionStatus.submitting,
        FormSubmissionStatus.success,
      ]),
    );

    await cubit.submitReport(userId: 'user_123', areaId: 'kimironko');

    await expectation;

    expect(cubit.state.submissionStatus, FormSubmissionStatus.success);

    expect(fakePhotoRepository.uploadPhotoCallCount, 1);
    expect(fakeRepository.createReportCallCount, 1);
  });

  test('prevents duplicate submission during photo upload', () async {
    completeForm();

    cubit.updatePhotoPath('/test/photo.jpg');

    final completer = Completer<String>();
    fakePhotoRepository.uploadCompleter = completer;

    // Start the first submission without awaiting it.
    final firstSubmission = cubit.submitReport(
      userId: 'user_123',
      areaId: 'kimironko',
    );

    expect(cubit.state.submissionStatus, FormSubmissionStatus.uploadingPhoto);

    expect(cubit.state.isBusy, isTrue);

    // Simulate the user pressing Submit again.
    await cubit.submitReport(userId: 'user_123', areaId: 'kimironko');

    expect(fakePhotoRepository.uploadPhotoCallCount, 1);
    expect(fakeRepository.createReportCallCount, 0);

    // Allow the original upload to finish.
    completer.complete(fakePhotoRepository.uploadedPhotoUrl);

    await firstSubmission;

    expect(fakePhotoRepository.uploadPhotoCallCount, 1);
    expect(fakeRepository.createReportCallCount, 1);

    expect(cubit.state.submissionStatus, FormSubmissionStatus.success);
  });

}
