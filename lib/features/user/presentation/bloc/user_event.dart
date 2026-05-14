part of 'user_bloc.dart';

sealed class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object?> get props => [];
}

class UserFetchRequested extends UserEvent {
  const UserFetchRequested();
}

class UserCreateRequested extends UserEvent {
  const UserCreateRequested({
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.role,
  });

  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String role;

  @override
  List<Object?> get props => [firstName, lastName, email, password, role];
}

class UserUpdateRequested extends UserEvent {
  const UserUpdateRequested({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.role,
  });

  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String role;

  @override
  List<Object?> get props => [id, firstName, lastName, email, role];
}

class UserDeleteRequested extends UserEvent {
  const UserDeleteRequested(this.id);

  final int id;

  @override
  List<Object?> get props => [id];
}
