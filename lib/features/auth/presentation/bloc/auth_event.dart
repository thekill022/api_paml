part of 'auth_bloc.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {}

class AuthLoginSubmitted extends AuthEvent {
  const AuthLoginSubmitted({required this.email, required this.password});

  final String email;
  final String password;

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterSubmitted extends AuthEvent {
  const AuthRegisterSubmitted({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;

  @override
  List<Object?> get props => [firstName, lastName, email, password];
}

class AuthLogoutRequested extends AuthEvent {}

class AuthSessionNameUpdated extends AuthEvent {
  const AuthSessionNameUpdated({
    required this.firstName,
    required this.lastName,
  });

  final String firstName;
  final String lastName;

  @override
  List<Object?> get props => [firstName, lastName];
}
