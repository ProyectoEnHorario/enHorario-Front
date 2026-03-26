import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:enhorario/features/auth/domain/repositories/login_account_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginUserState {
  const LoginUserState({
    this.isSubmitting = false,
    this.generalError,
    this.success = false,
  });

  final bool isSubmitting;
  final String? generalError;
  final bool success;

  LoginUserState copyWith({
    bool? isSubmitting,
    String? generalError,
    bool clearGeneralError = false,
    bool? success,
  }) {
    return LoginUserState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      generalError: clearGeneralError ? null : (generalError ?? this.generalError),
      success: success ?? this.success,
    );
  }
}

class LoginUserCubit extends Cubit<LoginUserState> {
  LoginUserCubit(this._loginService, this._sessionRepository)
      : super(const LoginUserState());

  final LoginAccountService _loginService;
  final AuthSessionRepository _sessionRepository;

  void clearError() {
    if (state.generalError == null) return;
    emit(state.copyWith(clearGeneralError: true));
  }

  Future<void> login({required String email, required String password}) async {
    if (state.isSubmitting) return;

    try {
      emit(
        state.copyWith(
          isSubmitting: true,
          clearGeneralError: true,
          success: false,
        ),
      );

      final result = await _loginService.login(
        LoginAccountRequest(email: email, password: password),
      );

      await result.fold(
        (failure) async {
          emit(
            state.copyWith(
              isSubmitting: false,
              generalError: failure.message,
              success: false,
            ),
          );
        },
        (successData) async {
          await _sessionRepository.saveSession(
            token: successData.token,
            email: successData.email,
            role: successData.role,
          );

          emit(
            state.copyWith(
              isSubmitting: false,
              clearGeneralError: true,
              success: true,
            ),
          );
        },
      );
    } catch (_) {
      emit(
        state.copyWith(
          isSubmitting: false,
          generalError: 'No fue posible completar el inicio de sesion.',
          success: false,
        ),
      );
    }
  }
}
