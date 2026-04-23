import 'package:enhorario/features/auth/domain/repositories/register_account_service.dart';
import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:enhorario/features/auth/domain/repositories/login_account_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterUserState {
  const RegisterUserState({
    this.isSubmitting = false,
    this.emailError,
    this.generalError,
    this.successMessage,
  });

  final bool isSubmitting;
  final String? emailError;
  final String? generalError;
  final String? successMessage;

  RegisterUserState copyWith({
    bool? isSubmitting,
    String? emailError,
    bool clearEmailError = false,
    String? generalError,
    bool clearGeneralError = false,
    String? successMessage,
    bool clearSuccessMessage = false,
  }) {
    return RegisterUserState(
      isSubmitting: isSubmitting ?? this.isSubmitting,
      emailError: clearEmailError ? null : (emailError ?? this.emailError),
      generalError: clearGeneralError ? null : (generalError ?? this.generalError),
      successMessage: clearSuccessMessage
          ? null
          : (successMessage ?? this.successMessage),
    );
  }
}

class RegisterUserCubit extends Cubit<RegisterUserState> {
  RegisterUserCubit(
    this._service,
    this._loginService,
    this._sessionRepository,
  ) : super(const RegisterUserState());

  final RegisterAccountService _service;
  final LoginAccountService _loginService;
  final AuthSessionRepository _sessionRepository;

  void clearFeedback() {
    emit(
      state.copyWith(
        clearEmailError: true,
        clearGeneralError: true,
        clearSuccessMessage: true,
      ),
    );
  }

  Future<void> submit(RegisterAccountRequest request) async {
    emit(
      state.copyWith(
        isSubmitting: true,
        clearEmailError: true,
        clearGeneralError: true,
        clearSuccessMessage: true,
      ),
    );

    final result = await _service.register(request);

    await result.fold(
      (failure) {
        final message = failure.message;
        final isEmailTaken = message.toLowerCase().contains('correo');

        emit(
          state.copyWith(
            isSubmitting: false,
            emailError: isEmailTaken ? message : null,
            generalError: isEmailTaken ? null : message,
          ),
        );
      },
      (_) async {
        final loginResult = await _loginService.login(
          LoginAccountRequest(
            email: request.email,
            password: request.password,
          ),
        );

        await loginResult.fold(
          (failure) async {
            emit(
              state.copyWith(
                isSubmitting: false,
                generalError:
                    'Registro completado, pero no fue posible iniciar sesion automaticamente. Inicia sesion manualmente.',
              ),
            );
          },
          (successData) async {
            await _sessionRepository.saveSession(
              token: successData.token,
              email: successData.email,
              role: successData.role,
              userId: successData.userId,
            );

            emit(
              state.copyWith(
                isSubmitting: false,
                successMessage: 'Registro completado correctamente.',
              ),
            );
          },
        );
      },
    );
  }
}
