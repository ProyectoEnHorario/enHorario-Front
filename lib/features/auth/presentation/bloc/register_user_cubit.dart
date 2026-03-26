import 'package:enhorario/features/auth/domain/repositories/register_account_service.dart';
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
  RegisterUserCubit(this._service) : super(const RegisterUserState());

  final RegisterAccountService _service;

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

    result.fold(
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
      (_) {
        emit(
          state.copyWith(
            isSubmitting: false,
            successMessage: 'Registro completado correctamente.',
          ),
        );
      },
    );
  }
}
