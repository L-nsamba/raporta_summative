import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/create_report.dart';
import 'package:raporta_frontend_backend_implementation/features/reports/domain/usecases/upload_report_photo.dart';

import '../../../../core/enums/report_category.dart';
import '../../../../core/enums/report_status.dart';
import '../../domain/entities/report.dart';
import 'report_form_state.dart';

class ReportFormCubit extends Cubit<ReportFormState> {
  final CreateReport createReport;
  final UploadReportPhoto uploadReportPhoto;

  ReportFormCubit({required this.createReport, required this.uploadReportPhoto})
    : super(const ReportFormState());

  // Prevent form changes during or after submission.
  bool get _canEdit =>
      !isClosed &&
      !state.isBusy &&
      state.submissionStatus != FormSubmissionStatus.success;

  // STEP 1: REPORT DETAILS

  void updateCategory(ReportCategory category) {
    if (!_canEdit) return;

    emit(state.copyWith(category: category, clearError: true));
  }

  void updateDescription(String description) {
    if (!_canEdit) return;

    emit(state.copyWith(description: description, clearError: true));
  }

  // Store the selected image locally.
  void updatePhotoPath(String? photoPath) {
    if (!_canEdit) return;

    if (photoPath == null || photoPath.isEmpty) {
      removePhoto();
      return;
    }

    // Selecting a new image invalidates the previous URL.
    emit(
      state.copyWith(
        photoPath: photoPath,
        clearPhotoUrl: true,
        clearError: true,
      ),
    );
  }

  void updatePhotoUrl(String? photoUrl) {
    if (!_canEdit) return;

    if (photoUrl == null || photoUrl.isEmpty) {
      removePhoto();
      return;
    }

    emit(
      state.copyWith(
        photoUrl: photoUrl,
        clearPhotoPath: true,
        clearError: true,
      ),
    );
  }

  void removePhoto() {
    if (!_canEdit) return;

    emit(
      state.copyWith(
        clearPhotoPath: true,
        clearPhotoUrl: true,
        clearError: true,
      ),
    );
  }

  // STEP 2: LOCATION

  void updateLocation({
    required double lat,
    required double lng,
    required String locationDescription,
  }) {
    if (!_canEdit) return;

    emit(
      state.copyWith(
        lat: lat,
        lng: lng,
        locationDescription: locationDescription,
        clearError: true,
      ),
    );
  }

  void updateLocationDescription(String description) {
    if (!_canEdit) return;

    emit(state.copyWith(locationDescription: description, clearError: true));
  }

  void clearSelectedLocation() {
    if (!_canEdit) return;

    emit(state.copyWith(clearLocation: true, clearError: true));
  }

  // FORM VALIDATION

  bool _validateDetails() {
    if (state.category == null) {
      emit(state.copyWith(errorMessage: 'Please select a report category.'));
      return false;
    }

    if (state.description.trim().isEmpty) {
      emit(
        state.copyWith(errorMessage: 'Please provide a report description.'),
      );
      return false;
    }

    return true;
  }

  bool _validateLocation() {
    final lat = state.lat;
    final lng = state.lng;

    if (lat == null || lng == null) {
      emit(
        state.copyWith(errorMessage: 'Please select a location on the map.'),
      );
      return false;
    }

    if (!lat.isFinite ||
        !lng.isFinite ||
        lat < -90 ||
        lat > 90 ||
        lng < -180 ||
        lng > 180) {
      emit(state.copyWith(errorMessage: 'Please select a valid location.'));
      return false;
    }

    if (state.locationDescription.trim().isEmpty) {
      emit(
        state.copyWith(errorMessage: 'Please provide a location description.'),
      );
      return false;
    }

    return true;
  }

  bool validateCurrentStep() {
    if (!_canEdit) return false;

    switch (state.currentStep) {
      case 0:
        return _validateDetails();

      case 1:
        return _validateLocation();

      default:
        return true;
    }
  }

  bool validateEntireForm() {
    if (!_canEdit) return false;

    return _validateDetails() && _validateLocation();
  }

  // FORM NAVIGATION

  void nextStep() {
    if (!_canEdit || state.currentStep >= 2) return;

    if (!validateCurrentStep()) return;

    emit(state.copyWith(currentStep: state.currentStep + 1, clearError: true));
  }

  void previousStep() {
    if (!_canEdit || state.currentStep <= 0) return;

    emit(state.copyWith(currentStep: state.currentStep - 1, clearError: true));
  }

  // FINAL SUBMISSION

  Future<void> submitReport({
    required String userId,
    required String areaId,
  }) async {
    // Prevent duplicate submissions.
    if (!_canEdit) return;

    // Validate the entire form, not only the current step.
    if (!validateEntireForm()) return;

    if (userId.trim().isEmpty || areaId.trim().isEmpty) {
      emit(
        state.copyWith(errorMessage: 'User or area information is missing.'),
      );
      return;
    }

    try {
      String? photoUrl = state.photoUrl;
      final photoPath = state.photoPath;

      // Upload only when a local image exists and has
      // not already been uploaded.
      if (photoPath != null && photoUrl == null) {
        emit(
          state.copyWith(
            submissionStatus: FormSubmissionStatus.uploadingPhoto,
            clearError: true,
          ),
        );

        photoUrl = await uploadReportPhoto(photoPath);

        if (isClosed) return;

        // Keep the uploaded URL for potential retries.
        emit(state.copyWith(photoUrl: photoUrl));
      }

      // Submit the report to Firestore.
      emit(
        state.copyWith(
          submissionStatus: FormSubmissionStatus.submitting,
          clearError: true,
        ),
      );

      final now = DateTime.now();

      final report = Report(
        reportId: '',
        userId: userId,
        areaId: areaId,
        category: state.category!,
        description: state.description.trim(),
        lat: state.lat!,
        lng: state.lng!,
        locationDescription: state.locationDescription.trim(),
        photoUrl: photoUrl,
        status: ReportStatus.pending,
        declineReason: null,
        declineFeedback: null,
        agencyId: null,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
      );

      final reportId = await createReport(report);

      if (isClosed) return;

      emit(
        state.copyWith(
          submissionStatus: FormSubmissionStatus.success,
          createdReportId: reportId,
        ),
      );
    } catch (e) {
      if (isClosed) return;

      final wasUploading =
          state.submissionStatus == FormSubmissionStatus.uploadingPhoto;

      emit(
        state.copyWith(
          submissionStatus: FormSubmissionStatus.failure,
          errorMessage: wasUploading
              ? 'Failed to upload photo. Please try again.'
              : 'Failed to submit report. Please try again.',
        ),
      );
    }
  }

  // RESET FORM

  void resetForm() {
    if (isClosed || state.isBusy) return;

    emit(const ReportFormState());
  }
}
