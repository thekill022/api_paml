part of 'user_bloc.dart';

sealed class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserInitial extends UserState {
  const UserInitial();
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserSubmitting extends UserState {
  const UserSubmitting();
}

class UserEmpty extends UserState {
  const UserEmpty();
}

class UserLoaded extends UserState {
  const UserLoaded(this.users);

  final List<UserModel> users;

  @override
  List<Object?> get props => [users];
}

class UserActionSuccess extends UserState {
  const UserActionSuccess(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}

class UserFailure extends UserState {
  const UserFailure(this.message);

  final String message;

  @override
  List<Object?> get props => [message];
}
