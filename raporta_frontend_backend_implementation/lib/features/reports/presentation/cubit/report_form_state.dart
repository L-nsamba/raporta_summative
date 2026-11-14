import 'package:equatable/equatable.dart';

import '../../../../core/enums/report_category.dart';

enum FormSubmissionStatus {
  initial,
  uploadingPhoto,
  submitting,
  success,
  failure,
}

class ReportFormState extends Equatable {
  final int currentStep;

  final ReportCategory? category;
  final String description;

  // Local image and uploaded Cloudinary URL.
  final String? photoPath;
  final String? photoUrl;

  final double? lat;
  final double? lng;
  final String locationDescription;

  final FormSubmissionStatus submissionStatus;
  final String? errorMessage;
  final String? createdReportId;

  const ReportFormState({
    this.currentStep = 0,
    this.category,
    this.description = '',
    this.photoPath,
    this.photoUrl,
    this.lat,
    this.lng,
    this.locationDescription = '',
    this.submissionStatus = FormSubmissionStatus.initial,
    this.errorMessage,
    this.createdReportId,
  });

  bool get isBusy =>
      submissionStatus == FormSubmissionStatus.uploadingPhoto ||
      submissionStatus == FormSubmissionStatus.submitting;

  bool get hasPhoto => photoPath != null || photoUrl != null;

  ReportFormState copyWith({
    int? currentStep,
    ReportCategory? category,
    String? description,
    String? photoPath,
    String? photoUrl,
    bool clearPhotoPath = false,
    bool clearPhotoUrl = false,
    double? lat,
    double? lng,
    String? locationDescription,
    FormSubmissionStatus? submissionStatus,
    String? errorMessage,
    String? createdReportId,
    bool clearError = false,
    bool clearLocation = false,
  }) {
    return ReportFormState(
      currentStep: currentStep ?? this.currentStep,
      category: category ?? this.category,
      description: description ?? this.description,

      photoPath: clearPhotoPath ? null : photoPath ?? this.photoPath,

      photoUrl: clearPhotoUrl ? null : photoUrl ?? this.photoUrl,

      lat: clearLocation ? null : lat ?? this.lat,
      lng: clearLocation ? null : lng ?? this.lng,

      locationDescription: clearLocation
          ? ''
          : locationDescription ?? this.locationDescription,

      submissionStatus: submissionStatus ?? this.submissionStatus,

      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,

      createdReportId: createdReportId ?? this.createdReportId,
    );
  }

  @override
  List<Object?> get props => [
    currentStep,
    category,
    description,
    photoPath,
    photoUrl,
    lat,
    lng,
    locationDescription,
    submissionStatus,
    errorMessage,
    createdReportId,
  ];
}
