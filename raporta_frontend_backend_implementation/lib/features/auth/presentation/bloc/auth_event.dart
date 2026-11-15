import 'package:equatable/equatable.dart';
import 'package:raporta_frontend_backend_implementation/features/auth/domain/entities/app_user.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

// check existing authentication session
class AuthCheckRequested extends AuthEvent {}

// authentication stream updates
class AuthStatusChanged extends AuthEvent {
  final AppUser? user;

  const AuthStatusChanged(this.user);

  @override
  List<Object?> get props => [user];
}

class AuthStreamFailed extends AuthEvent {
  const AuthStreamFailed();
}

// email registration
class AuthRegisterRequested extends AuthEvent {
  final String name;
  final String email;
  final String password;
  final String areaId;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.areaId,
  });

  @override
  List<Object?> get props => [name, email, password, areaId];
}

// email login
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

// google sign-in
class AuthGoogleSignInRequested extends AuthEvent {
  final String areaId;

  const AuthGoogleSignInRequested({required this.areaId});

  @override
  List<Object?> get props => [areaId];
}

// password reset
class AuthPasswordResetRequested extends AuthEvent {
  final String email;

  const AuthPasswordResetRequested({required this.email});

  @override
  List<Object?> get props => [email];
}

// email verification
class AuthEmailVerificationRequested extends AuthEvent {}

// Check whether the user has verified their email.
class AuthEmailVerificationCheckRequested extends AuthEvent {
  const AuthEmailVerificationCheckRequested();
}

// Update the authenticated user's profile
class AuthProfileUpdateRequested extends AuthEvent {
  final String name;
  final String areaId;

  const AuthProfileUpdateRequested({required this.name, required this.areaId});

  @override
  List<Object?> get props => [name, areaId];
}

// logout
class AuthLogoutRequested extends AuthEvent {}
