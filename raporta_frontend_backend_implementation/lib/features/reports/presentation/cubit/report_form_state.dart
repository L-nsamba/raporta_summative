import 'package:equatable/equatable.dart';

import '../../../../core/enums/report_category.dart';

enum FormSubmissionStatus { initial, submitting, success, failure }

class ReportFormState extends Equatable {
  final int currentStep;

  final ReportCategory? category;
  final String description;
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
    this.photoUrl,
    this.lat,
    this.lng,
    this.locationDescription = '',
    this.submissionStatus = FormSubmissionStatus.initial,
    this.errorMessage,
    this.createdReportId,
  });

  ReportFormState copyWith({
    int? currentStep,
    ReportCategory? category,
    String? description,
    String? photoUrl,
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
    photoUrl,
    lat,
    lng,
    locationDescription,
    submissionStatus,
    errorMessage,
    createdReportId,
  ];
}
