import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raporta_frontend_backend_implementation/core/enums/report_category.dart';

import '../../../../core/enums/report_status.dart';
import '../../domain/entities/report.dart';
import '../../domain/usecases/create_report.dart';
import 'report_form_state.dart';

class ReportFormCubit extends Cubit<ReportFormState> {
  final CreateReport createReport;

  ReportFormCubit({required this.createReport})
    : super(const ReportFormState());

  // STEP 1: REPORT DETAILS

  void updateCategory(ReportCategory category) {
    emit(state.copyWith(category: category, clearError: true));
  }

  void updateDescription(String description) {
    emit(state.copyWith(description: description, clearError: true));
  }

  void updatePhotoUrl(String? photoUrl) {
    if (photoUrl == null || photoUrl.isEmpty) {
      removePhoto();
      return;
    }

    emit(state.copyWith(photoUrl: photoUrl, clearError: true));
  }

  void removePhoto() {
    emit(state.copyWith(clearPhotoUrl: true, clearError: true));
  }

  // STEP 2: LOCATION

  void updateLocation({
    required double lat,
    required double lng,
    required String locationDescription,
  }) {
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
    emit(state.copyWith(locationDescription: description, clearError: true));
  }

  void clearSelectedLocation() {
    emit(state.copyWith(clearLocation: true, clearError: true));
  }

  // FORM NAVIGATION

  bool validateCurrentStep() {
    switch (state.currentStep) {
      case 0:
        if (state.category == null) {
          emit(
            state.copyWith(errorMessage: 'Please select a report category.'),
          );
          return false;
        }

        if (state.description.trim().isEmpty) {
          emit(
            state.copyWith(
              errorMessage: 'Please provide a report description.',
            ),
          );
          return false;
        }

        return true;

      case 1:
        if (state.lat == null || state.lng == null) {
          emit(
            state.copyWith(
              errorMessage: 'Please select a location on the map.',
            ),
          );
          return false;
        }

        if (state.locationDescription.trim().isEmpty) {
          emit(
            state.copyWith(
              errorMessage: 'Please provide a location description.',
            ),
          );
          return false;
        }

        return true;

      default:
        return true;
    }
  }

  bool validateEntireForm() {
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

    if (state.lat == null || state.lng == null) {
      emit(
        state.copyWith(errorMessage: 'Please select a location on the map.'),
      );
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

  void nextStep() {
    if (state.currentStep >= 2) return;

    if (!validateCurrentStep()) return;

    emit(state.copyWith(currentStep: state.currentStep + 1, clearError: true));
  }

  void previousStep() {
    if (state.currentStep <= 0) return;

    emit(state.copyWith(currentStep: state.currentStep - 1, clearError: true));
  }

  // FINAL SUBMISSION

  Future<void> submitReport({
    required String userId,
    required String areaId,
  }) async {
    if (state.submissionStatus == FormSubmissionStatus.submitting ||
        state.submissionStatus == FormSubmissionStatus.success) {
      return;
    }

    // Validate the complete form before submission.
    if (!validateCurrentStep()) {
      return;
    }

    emit(
      state.copyWith(
        submissionStatus: FormSubmissionStatus.submitting,
        clearError: true,
      ),
    );

    try {
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
        photoUrl: state.photoUrl,
        status: ReportStatus.pending,
        declineReason: null,
        declineFeedback: null,
        agencyId: null,
        createdAt: now,
        updatedAt: now,
        deletedAt: null,
      );

      final reportId = await createReport(report);

      emit(
        state.copyWith(
          submissionStatus: FormSubmissionStatus.success,
          createdReportId: reportId,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          submissionStatus: FormSubmissionStatus.failure,
          errorMessage: 'Failed to submit report. Please try again.',
        ),
      );
    }
  }

  // RESET FORM

  void resetForm() {
    emit(const ReportFormState());
  }
}
