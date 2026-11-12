import 'package:equatable/equatable.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/entities/app_user.dart';

enum AuthStatus { unknown, checking, authenticated, unauthenticated }

enum AuthOperationStatus { initial, loading, success, failure }

class AuthState extends Equatable {
  final AuthStatus status;
  final AuthOperationStatus operationStatus;
  final AppUser? user;
  final String? errorMessage;
  final String? successMessage;

  const AuthState({
    this.status = AuthStatus.unknown,
    this.operationStatus = AuthOperationStatus.initial,
    this.user,
    this.errorMessage,
    this.successMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    AuthOperationStatus? operationStatus,
    AppUser? user,
    bool clearUser = false,
    String? errorMessage,
    String? successMessage,
    bool clearMessages = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      operationStatus: operationStatus ?? this.operationStatus,
      user: clearUser ? null : (user ?? this.user),
      errorMessage: errorMessage ?? (clearMessages ? null : this.errorMessage),

      successMessage:
          successMessage ?? (clearMessages ? null : this.successMessage),
    );
  }

  @override
  List<Object?> get props => [
    status,
    operationStatus,
    user,
    errorMessage,
    successMessage,
  ];
}
