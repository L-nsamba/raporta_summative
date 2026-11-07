import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/app_user.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  StreamSubscription<AppUser?>? _authSubscription;

  AuthBloc({required this.authRepository}) : super(const AuthState()) {
    on<AuthCheckRequested>(_onAuthCheckRequested);
    on<AuthStatusChanged>(_onAuthStatusChanged);
    on<AuthStreamFailed>(_onAuthStreamFailed);
    on<AuthRegisterRequested>(_onRegisterRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthGoogleSignInRequested>(_onGoogleSignInRequested);
    on<AuthPasswordResetRequested>(_onPasswordResetRequested);
    on<AuthEmailVerificationRequested>(_onEmailVerificationRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  // check and monitor authentication state
  Future<void> _onAuthCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(state.copyWith(status: AuthStatus.checking, clearMessages: true));
    await _authSubscription?.cancel();
    _authSubscription = authRepository.authStateChanges.listen(
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

  // registration
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
      final user = await authRepository.registerWithEmail(
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

  // email login
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
      final user = await authRepository.signInWithEmail(
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

  // google login
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
      final user = await authRepository.signInWithGoogle(areaId: event.areaId);
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

  // password reset
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
      await authRepository.sendPasswordReset(event.email);
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

  // email verification
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
      await authRepository.sendEmailVerification();
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

  // logout
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
      await authRepository.signOut();
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

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    return super.close();
  }
}