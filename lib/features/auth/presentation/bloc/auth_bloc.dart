import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/auth_session.dart';
import '../../data/auth_repository.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc(this._authRepository) : super(const AuthInitial()) {
    on<AuthStarted>(_onStarted);
    on<AuthLoginSubmitted>(_onLoginSubmitted);
    on<AuthRegisterSubmitted>(_onRegisterSubmitted);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  final AuthRepository _authRepository;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    emit(const AuthLoading());
    await Future<void>.delayed(const Duration(milliseconds: 700));
    try {
      final session = await _authRepository.getSavedSession();
      emit(
        session == null ? const AuthUnauthenticated() : Authenticated(session),
      );
    } on AuthException {
      await _authRepository.logout();
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLoginSubmitted(
    AuthLoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final session = await _authRepository.login(
        email: event.email,
        password: event.password,
      );
      emit(Authenticated(session));
    } on AuthException catch (error) {
      emit(AuthFailure(error.message));
      emit(const AuthUnauthenticated());
    } catch (_) {
      emit(const AuthFailure('Tidak dapat terhubung ke server'));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onRegisterSubmitted(
    AuthRegisterSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await _authRepository.registerMember(
        firstName: event.firstName,
        lastName: event.lastName,
        email: event.email,
        password: event.password,
      );
      emit(const RegisterSuccess());
      emit(const AuthUnauthenticated());
    } on AuthException catch (error) {
      emit(AuthFailure(error.message));
      emit(const AuthUnauthenticated());
    } catch (_) {
      emit(const AuthFailure('Tidak dapat terhubung ke server'));
      emit(const AuthUnauthenticated());
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    await _authRepository.logout();
    emit(const AuthUnauthenticated());
  }
}
