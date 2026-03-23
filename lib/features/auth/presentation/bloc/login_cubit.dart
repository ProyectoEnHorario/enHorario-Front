import 'package:enhorario/features/auth/domain/entities/app_user.dart';
import 'package:enhorario/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginState {
  const LoginState({this.isLoading = false, this.error, this.user});

  final bool isLoading;
  final String? error;
  final AppUser? user;

  LoginState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    AppUser? user,
  }) {
    return LoginState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      user: user ?? this.user,
    );
  }
}

class LoginCubit extends Cubit<LoginState> {
  LoginCubit(this._authRepository) : super(const LoginState());

  final AuthRepository _authRepository;

  Future<void> login({required String email, required String password}) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _authRepository.login(
      email: email,
      password: password,
    );
    result.fold(
      (failure) =>
          emit(state.copyWith(isLoading: false, error: failure.message)),
      (user) =>
          emit(state.copyWith(isLoading: false, user: user, clearError: true)),
    );
  }
}
