import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:raporta_frontend_backend_implementation/features/auth/domain/entities/app_user.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/register_with_email.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/sign_in_with_email.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/sign_in_with_google.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/send_email_verification.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/send_password_reset.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/get_current_user.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/watch_auth_state.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/sign_out.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/usecases/update_profile.dart';

import 'package:raporta_frontend_backend_implementation/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/presentation/bloc/auth_event.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/presentation/bloc/auth_state.dart';

import 'package:raporta_frontend_backend_implementation/core/enums/user_role.dart';

// Mock use cases
class MockRegisterWithEmail extends Mock implements RegisterWithEmail {}

class MockSignInWithEmail extends Mock implements SignInWithEmail {}

class MockSignInWithGoogle extends Mock implements SignInWithGoogle {}

class MockSendEmailVerification extends Mock implements SendEmailVerification {}

class MockSendPasswordReset extends Mock implements SendPasswordReset {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockWatchAuthState extends Mock implements WatchAuthState {}

class MockSignOut extends Mock implements SignOut {}

class MockUpdateProfile extends Mock implements UpdateProfile {}

void main() {
  late MockRegisterWithEmail registerWithEmail;
  late MockSignInWithEmail signInWithEmail;
  late MockSignInWithGoogle signInWithGoogle;
  late MockSendEmailVerification sendEmailVerification;
  late MockSendPasswordReset sendPasswordReset;
  late MockGetCurrentUser getCurrentUser;
  late MockWatchAuthState watchAuthState;
  late MockSignOut signOut;
  late MockUpdateProfile updateProfile;

  final now = DateTime(2026, 11, 11);

  final originalUser = AppUser(
    userId: 'citizen-1',
    name: 'Original Name',
    email: 'citizen@example.com',
    role: UserRole.citizen,
    areaId: 'area-1',
    createdAt: now,
    updatedAt: now,
  );

  final updatedUser = AppUser(
    userId: 'citizen-1',
    name: 'Updated Name',
    email: 'citizen@example.com',
    role: UserRole.citizen,
    areaId: 'area-2',
    createdAt: now,
    updatedAt: now.add(const Duration(minutes: 5)),
  );

  AuthBloc buildBloc() {
    return AuthBloc(
      registerWithEmail: registerWithEmail,
      signInWithEmail: signInWithEmail,
      signInWithGoogle: signInWithGoogle,
      sendEmailVerification: sendEmailVerification,
      sendPasswordReset: sendPasswordReset,
      getCurrentUser: getCurrentUser,
      watchAuthState: watchAuthState,
      signOut: signOut,
      updateProfile: updateProfile,
    );
  }

  setUp(() {
    registerWithEmail = MockRegisterWithEmail();
    signInWithEmail = MockSignInWithEmail();
    signInWithGoogle = MockSignInWithGoogle();
    sendEmailVerification = MockSendEmailVerification();
    sendPasswordReset = MockSendPasswordReset();
    getCurrentUser = MockGetCurrentUser();
    watchAuthState = MockWatchAuthState();
    signOut = MockSignOut();
    updateProfile = MockUpdateProfile();
  });

  blocTest<AuthBloc, AuthState>(
    'successful profile update refreshes the authenticated user',
    build: () {
      when(() => updateProfile(name: 'Updated Name', areaId: 'area-2'))
          .thenAnswer((_) async => updatedUser);

      return buildBloc();
    },
    seed: () => AuthState(status: AuthStatus.authenticated, user: originalUser),
    act: (bloc) => bloc.add(
      const AuthProfileUpdateRequested(name: 'Updated Name', areaId: 'area-2'),
    ),
    expect: () => [
      isA<AuthState>()
          .having(
            (state) => state.operationStatus,
            'operation status',
            AuthOperationStatus.loading,
          )
          .having((state) => state.user, 'original user', originalUser),
      isA<AuthState>()
          .having(
            (state) => state.operationStatus,
            'operation status',
            AuthOperationStatus.success,
          )
          .having((state) => state.user, 'updated user', updatedUser)
          .having(
            (state) => state.successMessage,
            'success message',
            'Profile updated successfully.',
          ),
    ],
    verify: (_) {
      verify(() => updateProfile(name: 'Updated Name', areaId: 'area-2'))
          .called(1);
    },
  );

  blocTest<AuthBloc, AuthState>(
    'failed profile update preserves the existing user',
    build: () {
      when(() => updateProfile(name: 'Updated Name', areaId: 'area-2'))
          .thenThrow(Exception('Firestore permission denied'));

      return buildBloc();
    },
    seed: () => AuthState(status: AuthStatus.authenticated, user: originalUser),
    act: (bloc) => bloc.add(
      const AuthProfileUpdateRequested(name: 'Updated Name', areaId: 'area-2'),
    ),
    expect: () => [
      isA<AuthState>().having(
        (state) => state.operationStatus,
        'operation status',
        AuthOperationStatus.loading,
      ),
      isA<AuthState>()
          .having(
            (state) => state.operationStatus,
            'operation status',
            AuthOperationStatus.failure,
          )
          .having((state) => state.user, 'unchanged user', originalUser)
          .having(
            (state) => state.errorMessage,
            'error message',
            'Unable to update your profile. Please try again.',
          ),
    ],
  );

  blocTest<AuthBloc, AuthState>(
    'unauthenticated user cannot update their profile',
    build: buildBloc,
    seed: () => const AuthState(status: AuthStatus.unauthenticated),
    act: (bloc) => bloc.add(
      const AuthProfileUpdateRequested(name: 'Updated Name', areaId: 'area-2'),
    ),
    expect: () => [
      isA<AuthState>()
          .having(
            (state) => state.operationStatus,
            'operation status',
            AuthOperationStatus.failure,
          )
          .having((state) => state.user, 'user', null),
    ],
    verify: (_) {
      verifyNever(
        () => updateProfile(
          name: any(named: 'name'),
          areaId: any(named: 'areaId'),
        ),
      );
    },
  );

  blocTest<AuthBloc, AuthState>(
    'stale profile update cannot replace another authenticated user',
    build: () {
      final completer = Completer<AppUser>();

      when(() => updateProfile(name: 'Updated Name', areaId: 'area-2'))
          .thenAnswer((_) => completer.future);

      // Complete the pending update after authentication changes.
      Future<void>.delayed(
        const Duration(milliseconds: 20),
        () => completer.complete(updatedUser),
      );

      return buildBloc();
    },
    seed: () => AuthState(status: AuthStatus.authenticated, user: originalUser),
    act: (bloc) async {
      bloc.add(
        const AuthProfileUpdateRequested(
          name: 'Updated Name',
          areaId: 'area-2',
        ),
      );

      await Future<void>.delayed(const Duration(milliseconds: 10));

      bloc.add(
        AuthStatusChanged(
          AppUser(
            userId: 'citizen-2',
            name: 'Another User',
            email: 'another@example.com',
            role: UserRole.citizen,
            areaId: 'area-1',
            createdAt: now,
            updatedAt: now,
          ),
        ),
      );
    },
    expect: () => [
      isA<AuthState>().having(
        (state) => state.operationStatus,
        'operation status',
        AuthOperationStatus.loading,
      ),
      isA<AuthState>().having(
        (state) => state.user?.userId,
        'changed user ID',
        'citizen-2',
      ),
    ],
  );
}
