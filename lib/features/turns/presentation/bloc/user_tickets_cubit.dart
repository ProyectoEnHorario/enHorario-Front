import 'package:enhorario/features/turns/data/models/turn_model.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserTicketsState {
  const UserTicketsState({
    this.tickets = const [],
    this.isLoading = false,
    this.isCreatingTurn = false,
    this.isDeletingTurn = false,
    this.error,
    this.successMessage,
  });

  final List<TurnModel> tickets;
  final bool isLoading;
  final bool isCreatingTurn;
  final bool isDeletingTurn;
  final String? error;
  final String? successMessage;

  UserTicketsState copyWith({
    List<TurnModel>? tickets,
    bool? isLoading,
    bool? isCreatingTurn,
    bool? isDeletingTurn,
    String? error,
    String? successMessage,
    bool clearError = false,
    bool clearSuccessMessage = false,
  }) {
    return UserTicketsState(
      tickets: tickets ?? this.tickets,
      isLoading: isLoading ?? this.isLoading,
      isCreatingTurn: isCreatingTurn ?? this.isCreatingTurn,
      isDeletingTurn: isDeletingTurn ?? this.isDeletingTurn,
      error: clearError ? null : (error ?? this.error),
      successMessage: clearSuccessMessage ? null : (successMessage ?? this.successMessage),
    );
  }
}

class UserTicketsCubit extends Cubit<UserTicketsState> {
  UserTicketsCubit() : super(const UserTicketsState());

  /// Simular carga de tickets del usuario desde localStorage o API
  Future<void> loadUserTickets() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    try {
      // TODO: Implementar carga real desde API
      // Por ahora, simular con lista vacía
      emit(state.copyWith(
        tickets: [],
        isLoading: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Error al cargar tickets: $e',
        isLoading: false,
      ));
    }
  }

  /// Crear un nuevo ticket (turno)
  Future<void> createTurn({
    required String establishmentId,
    required bool isPriority,
    String? priorityReason,
  }) async {
    emit(state.copyWith(isCreatingTurn: true, clearError: true));
    try {
      // TODO: Implementar creación real de turno en API
      // Por ahora, simular con un ticket local
      final newTurn = TurnModel(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        userId: 'current_user', // Se obtiene de sesión
        establishmentId: establishmentId,
        codigo: 'T-${DateTime.now().millisecondsSinceEpoch.toString().substring(10)}',
        tipo: isPriority ? 'preferencial' : 'regular',
        estado: 'en_espera',
        posicion: 1,
        solicitadoEn: DateTime.now(),
      );

      final updatedTickets = [...state.tickets, newTurn];
      emit(state.copyWith(
        tickets: updatedTickets,
        isCreatingTurn: false,
        successMessage: 'Ticket creado exitosamente',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Error al crear ticket: $e',
        isCreatingTurn: false,
      ));
    }
  }

  /// Eliminar un ticket
  Future<void> deleteTurn(String turnId) async {
    emit(state.copyWith(isDeletingTurn: true, clearError: true));
    try {
      // TODO: Implementar eliminación real en API
      final updatedTickets = state.tickets
          .where((turn) => turn.id != turnId)
          .toList();

      emit(state.copyWith(
        tickets: updatedTickets,
        isDeletingTurn: false,
        successMessage: 'Ticket eliminado exitosamente',
        clearError: true,
      ));
    } catch (e) {
      emit(state.copyWith(
        error: 'Error al eliminar ticket: $e',
        isDeletingTurn: false,
      ));
    }
  }

  /// Limpiar mensajes de éxito
  void clearSuccessMessage() {
    emit(state.copyWith(successMessage: '', clearSuccessMessage: true));
  }

  /// Limpiar errores
  void clearError() {
    emit(state.copyWith(error: '', clearError: true));
  }
}
