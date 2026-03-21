import 'package:enhorario/features/auth/domain/entities/app_user.dart';
import 'package:enhorario/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterState {
  const RegisterState({this.isLoading = false, this.error, this.user});

  final bool isLoading;
  final String? error;
  final AppUser? user;

  RegisterState copyWith({
    bool? isLoading,
    String? error,
    bool clearError = false,
    AppUser? user,
  }) {
    return RegisterState(
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      user: user ?? this.user,
    );
  }
}

class RegisterCubit extends Cubit<RegisterState> {
  RegisterCubit(this._authRepository) : super(const RegisterState());

  final AuthRepository _authRepository;

  Future<void> register({
    required String nombre,
    required String apellido,
    required String email,
    String? telefono,
    required String password,
  }) async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _authRepository.register(
      nombre: nombre,
      apellido: apellido,
      email: email,
      telefono: telefono,
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
