import 'package:enhorario/features/auth/domain/repositories/password_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

enum PasswordStatus { initial, loading, success, error }

class PasswordState {
  const PasswordState({
    this.status = PasswordStatus.initial,
    this.message,
    this.error,
    this.resetToken,
  });

  final PasswordStatus status;
  final String? message;
  final String? error;
  final String? resetToken;

  PasswordState copyWith({
    PasswordStatus? status,
    String? message,
    String? error,
    String? resetToken,
    bool clearError = false,
    bool clearMessage = false,
  }) {
    return PasswordState(
      status: status ?? this.status,
      message: clearMessage ? null : (message ?? this.message),
      error: clearError ? null : (error ?? this.error),
      resetToken: resetToken ?? this.resetToken,
    );
  }
}

class PasswordCubit extends Cubit<PasswordState> {
  PasswordCubit(this._passwordRepository) : super(const PasswordState());

  final PasswordRepository _passwordRepository;

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    if (state.status == PasswordStatus.loading) return;

    emit(state.copyWith(status: PasswordStatus.loading, clearError: true, clearMessage: true));

    final result = await _passwordRepository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );

    result.fold(
      (failure) => emit(state.copyWith(status: PasswordStatus.error, error: failure.message)),
      (message) => emit(state.copyWith(status: PasswordStatus.success, message: message)),
    );
  }

  Future<void> forgotPassword(String email) async {
    if (state.status == PasswordStatus.loading) return;

    emit(state.copyWith(status: PasswordStatus.loading, clearError: true, clearMessage: true));

    final result = await _passwordRepository.forgotPassword(email);

    result.fold(
      (failure) => emit(state.copyWith(status: PasswordStatus.error, error: failure.message)),
      (token) => emit(state.copyWith(
        status: PasswordStatus.success,
        message: 'Se ha enviado un correo con las instrucciones.',
        resetToken: token,
      )),
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    if (state.status == PasswordStatus.loading) return;

    emit(state.copyWith(status: PasswordStatus.loading, clearError: true, clearMessage: true));

    final result = await _passwordRepository.resetPassword(
      token: token,
      newPassword: newPassword,
      confirmNewPassword: confirmNewPassword,
    );

    result.fold(
      (failure) => emit(state.copyWith(status: PasswordStatus.error, error: failure.message)),
      (message) => emit(state.copyWith(status: PasswordStatus.success, message: message, resetToken: null)),
    );
  }

  void clearError() => emit(state.copyWith(clearError: true));
  void resetState() => emit(const PasswordState());
}
