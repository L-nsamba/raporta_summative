import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/update_profile.dart';

import '../../domain/entities/app_user.dart';
import '../../domain/usecases/get_current_user.dart';
import '../../domain/usecases/register_with_email.dart';
import '../../domain/usecases/send_email_verification.dart';
import '../../domain/usecases/send_password_reset.dart';
import '../../domain/usecases/sign_in_with_email.dart';
import '../../domain/usecases/sign_in_with_google.dart';
import '../../domain/usecases/sign_out.dart';
import '../../domain/usecases/watch_auth_state.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final RegisterWithEmail registerWithEmail;
  final SignInWithEmail signInWithEmail;
  final SignInWithGoogle signInWithGoogle;
  final SendEmailVerification sendEmailVerification;
  final SendPasswordReset sendPasswordReset;
  final GetCurrentUser getCurrentUser;
  final WatchAuthState watchAuthState;
  final SignOut signOut;
  final UpdateProfile updateProfile;

  StreamSubscription<AppUser?>? _authSubscription;

  AuthBloc({
    required this.registerWithEmail,
    required this.signInWithEmail,
    required this.signInWithGoogle,
    required this.sendEmailVerification,
    required this.sendPasswordReset,
    required this.getCurrentUser,
    required this.watchAuthState,
    required this.signOut,
    required this.updateProfile,
  }) : super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthStreamFailed>(_onAuthStreamFailed);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthEmailVerificationRequested>(_onEmailVerificationRequested);
    on<AuthProfileUpdateRequested>(_onProfileUpdateRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.checking, clearMessages: true));
    await _authSubscription?.cancel();
    _authSubscription = watchAuthState().listen(
      (user) {
        add(AuthStatusChanged(user));
      },
      onError: (error) {
        add(const AuthStreamFailed());
      },
    );
  }

  Future<void> _onAuthStatusChanged(
    AuthStatusChanged event,
    Emitter<AuthState> emit,
  ) async {
    if (event.user == null) {
      emit(state.copyWith(status: AuthStatus.unauthenticated, clearUser: true));
    } else {
      emit(state.copyWith(status: AuthStatus.authenticated, user: event.user));
    }
  }

  void _onAuthStreamFailed(AuthStreamFailed event, Emitter<AuthState> emit) {
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        clearUser: true,
        errorMessage: 'Unable to check authentication status.',
      ),
    );
  }

  Future<void> _onRegisterRequested(
    AuthRegisterRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        operationStatus: AuthOperationStatus.loading,
        clearMessages: true,
      ),
    );
    try {
      final user = await registerWithEmail(
        name: event.name,
        email: event.email,
        password: event.password,
        areaId: event.areaId,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          operationStatus: AuthOperationStatus.success,
          user: user,
          successMessage: 'Registration successful.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          operationStatus: AuthOperationStatus.failure,
          errorMessage: 'Registration failed. Please try again.',
        ),
      );
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        operationStatus: AuthOperationStatus.loading,
        clearMessages: true,
      ),
    );
    try {
      final user = await signInWithEmail(
        email: event.email,
        password: event.password,
      );
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          operationStatus: AuthOperationStatus.success,
          user: user,
          successMessage: 'Login successful.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          operationStatus: AuthOperationStatus.failure,
          errorMessage: 'Login failed. Please check your credentials.',
        ),
      );
    }
  }

  Future<void> _onGoogleSignInRequested(
    AuthGoogleSignInRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        operationStatus: AuthOperationStatus.loading,
        clearMessages: true,
      ),
    );
    try {
      final user = await signInWithGoogle(areaId: event.areaId);
      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          operationStatus: AuthOperationStatus.success,
          user: user,
          successMessage: 'Google sign-in successful.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          operationStatus: AuthOperationStatus.failure,
          errorMessage: 'Google sign-in failed. Please try again.',
        ),
      );
    }
  }

  Future<void> _onPasswordResetRequested(
    AuthPasswordResetRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        operationStatus: AuthOperationStatus.loading,
        clearMessages: true,
      ),
    );
    try {
      await sendPasswordReset(event.email);
      emit(
        state.copyWith(
          operationStatus: AuthOperationStatus.success,
          successMessage: 'Password reset email sent.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          operationStatus: AuthOperationStatus.failure,
          errorMessage: 'Unable to send password reset email.',
        ),
      );
    }
  }

  Future<void> _onEmailVerificationRequested(
    AuthEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        operationStatus: AuthOperationStatus.loading,
        clearMessages: true,
      ),
    );
    try {
      await sendEmailVerification();
      emit(
        state.copyWith(
          operationStatus: AuthOperationStatus.success,
          successMessage: 'Verification email sent.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          operationStatus: AuthOperationStatus.failure,
          errorMessage: 'Unable to send verification email.',
        ),
      );
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        operationStatus: AuthOperationStatus.loading,
        clearMessages: true,
      ),
    );
    try {
      await signOut();
      emit(
        state.copyWith(
          status: AuthStatus.unauthenticated,
          operationStatus: AuthOperationStatus.success,
          clearUser: true,
          successMessage: 'Logged out successfully.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          operationStatus: AuthOperationStatus.failure,
          errorMessage: 'Logout failed. Please try again.',
        ),
      );
    }
  }

  Future<void> _onProfileUpdateRequested(
    AuthProfileUpdateRequested event,
    Emitter<AuthState> emit,
  ) async {
    if (state.status != AuthStatus.authenticated || state.user == null) {
      emit(
        state.copyWith(
          operationStatus: AuthOperationStatus.failure,
          clearMessages: true,
          errorMessage: 'You must be signed in to update your profile.',
        ),
      );
      return;
    }

    if (state.operationStatus == AuthOperationStatus.loading) {
      return;
    }

    emit(
      state.copyWith(
        operationStatus: AuthOperationStatus.loading,
        clearMessages: true,
      ),
    );

    try {
      final updatedUser = await updateProfile(
        name: event.name,
        areaId: event.areaId,
      );

      // Ensure the account has not changed while the request was running.
      if (state.user?.userId != updatedUser.userId ||
          state.status != AuthStatus.authenticated) {
        return;
      }

      emit(
        state.copyWith(
          status: AuthStatus.authenticated,
          operationStatus: AuthOperationStatus.success,
          user: updatedUser,
          clearMessages: true,
          successMessage: 'Profile updated successfully.',
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          operationStatus: AuthOperationStatus.failure,
          clearMessages: true,
          errorMessage: 'Unable to update your profile. Please try again.',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}
