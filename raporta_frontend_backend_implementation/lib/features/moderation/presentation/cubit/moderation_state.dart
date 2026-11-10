import 'package:equatable/equatable.dart';

enum ModerationStatus { initial, submitting, success, failure }

class ModerationState extends Equatable {
  final ModerationStatus status;
  final String? errorMessage;
  final String? successMessage;

  const ModerationState({
    this.status = ModerationStatus.initial,
    this.errorMessage,
    this.successMessage,
  });

  ModerationState copyWith({
    ModerationStatus? status,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return ModerationState(
      status: status ?? this.status,
      errorMessage: clearMessages ? null : errorMessage ?? this.errorMessage,
      successMessage: clearMessages
          ? null
          : successMessage ?? this.successMessage,
    );
  }

  @override
  List<Object?> get props => [status, errorMessage, successMessage];
}
