import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/user_model.dart';
import '../../data/repositories/user_repository.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  UserBloc(this._userRepository) : super(const UserInitial()) {
    on<UserFetchRequested>(_onFetchRequested);
    on<UserCreateRequested>(_onCreateRequested);
    on<UserUpdateRequested>(_onUpdateRequested);
    on<UserDeleteRequested>(_onDeleteRequested);
  }

  final UserRepository _userRepository;

  Future<void> _onFetchRequested(
    UserFetchRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final users = await _userRepository.fetchUsers();
      emit(users.isEmpty ? const UserEmpty() : UserLoaded(users));
    } on UserException catch (error) {
      emit(UserFailure(error.message));
    } catch (_) {
      emit(const UserFailure('Tidak dapat terhubung ke server'));
    }
  }

  Future<void> _onCreateRequested(
    UserCreateRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserSubmitting());
    try {
      await _userRepository.createUser(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
        role: event.role,
      );
      final users = await _userRepository.fetchUsers();
      emit(const UserActionSuccess('User berhasil ditambahkan'));
      emit(users.isEmpty ? const UserEmpty() : UserLoaded(users));
    } on UserException catch (error) {
      emit(UserFailure(error.message));
    } catch (_) {
      emit(const UserFailure('Tidak dapat terhubung ke server'));
    }
  }

  Future<void> _onUpdateRequested(
    UserUpdateRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserSubmitting());
    try {
      await _userRepository.updateUser(
        id: event.id,
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        role: event.role,
      );
      final users = await _userRepository.fetchUsers();
      emit(const UserActionSuccess('User berhasil diubah'));
      emit(users.isEmpty ? const UserEmpty() : UserLoaded(users));
    } on UserException catch (error) {
      emit(UserFailure(error.message));
    } catch (_) {
      emit(const UserFailure('Tidak dapat terhubung ke server'));
    }
  }

  Future<void> _onDeleteRequested(
    UserDeleteRequested event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserSubmitting());
    try {
      await _userRepository.deleteUser(event.id);
      final users = await _userRepository.fetchUsers();
      emit(const UserActionSuccess('User berhasil dihapus'));
      emit(users.isEmpty ? const UserEmpty() : UserLoaded(users));
    } on UserException catch (error) {
      emit(UserFailure(error.message));
    } catch (_) {
      emit(const UserFailure('Tidak dapat terhubung ke server'));
    }
  }
}
