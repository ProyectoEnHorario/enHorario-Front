import 'package:enhorario/features/auth/data/repositories/account_deletion_service.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class DeleteAccountState {
  const DeleteAccountState({
    this.isDeleting = false,
    this.isDeleted = false,
    this.error,
  });

  final bool isDeleting;
  final bool isDeleted;
  final String? error;

  DeleteAccountState copyWith({
    bool? isDeleting,
    bool? isDeleted,
    String? error,
    bool clearError = false,
  }) {
    return DeleteAccountState(
      isDeleting: isDeleting ?? this.isDeleting,
      isDeleted: isDeleted ?? this.isDeleted,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class DeleteAccountCubit extends Cubit<DeleteAccountState> {
  DeleteAccountCubit(this._accountDeletionService)
      : super(const DeleteAccountState());

  final AccountDeletionService _accountDeletionService;

  /// Eliminar la cuenta del usuario autenticado
  Future<void> deleteAccount() async {
    emit(state.copyWith(isDeleting: true, clearError: true));
    try {
      final result = await _accountDeletionService.deleteCurrentUserAccount();

      // Usar fold para manejar ambos casos (Left y Right)
      final newState = result.fold(
        (failure) {
          // Caso de error (Left)
          return state.copyWith(
            isDeleting: false,
            error: failure.message,
          );
        },
        (success) {
          // Caso de éxito (Right)
          return state.copyWith(
            isDeleting: false,
            isDeleted: true,
          );
        },
      );

      emit(newState);
    } catch (e) {
      emit(state.copyWith(
        isDeleting: false,
        error: 'Error inesperado: $e',
      ));
    }
  }

  /// Limpiar errores
  void clearError() {
    emit(state.copyWith(error: '', clearError: true));
  }
}
