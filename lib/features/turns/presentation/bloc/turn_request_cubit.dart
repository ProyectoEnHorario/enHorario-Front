import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/features/turns/data/models/turn_model.dart';
import 'package:enhorario/features/turns/data/repositories/railway_turn_repository.dart';

abstract class TurnRequestState {
  final TurnModel? activeTurn;
  TurnRequestState({this.activeTurn});
}

class TurnRequestInitial extends TurnRequestState {
  TurnRequestInitial({super.activeTurn});
}

class TurnRequestLoading extends TurnRequestState {
  TurnRequestLoading({super.activeTurn});
}

class TurnRequestSuccess extends TurnRequestState {
  final String ticketCode;
  TurnRequestSuccess(this.ticketCode, {super.activeTurn});
}

class TurnRequestError extends TurnRequestState {
  final String message;
  TurnRequestError(this.message, {super.activeTurn});
}

class TurnRequestCancelling extends TurnRequestState {
  TurnRequestCancelling({super.activeTurn});
}

class TurnRequestCubit extends Cubit<TurnRequestState> {
  final RailwayTurnRepository _repository;

  TurnRequestCubit(this._repository) : super(TurnRequestInitial());

  // ENH-339: Validar si el usuario ya tiene un turno activo en el establecimiento
  Future<void> checkActiveTurn(String establishmentId) async {
    emit(TurnRequestLoading(activeTurn: state.activeTurn));
    
    final result = await _repository.fetchDailyTurns(
      establishmentId: establishmentId,
      date: DateTime.now(),
    );

    result.fold(
      (failure) => emit(TurnRequestInitial()), // Silenciamos error aquí
      (turns) {
        // En una implementación real, buscaríamos por userId (que vendría del AuthCubit)
        // Por ahora, para la demo, simularemos si hay turnos en la lista
        if (turns.isNotEmpty) {
          emit(TurnRequestInitial(activeTurn: turns.first));
        } else {
          emit(TurnRequestInitial());
        }
      },
    );
  }

  Future<void> requestTurn({
    required String establishmentId,
    required bool isPriority,
    String? priorityReason,
  }) async {
    emit(TurnRequestLoading(activeTurn: state.activeTurn));

    final result = await _repository.createTurn(
      establishmentId: establishmentId,
      isPriority: isPriority,
      priorityReason: isPriority ? priorityReason : null,
    );

    result.fold(
      (failure) => emit(TurnRequestError(failure.message, activeTurn: state.activeTurn)),
      (turn) => emit(TurnRequestSuccess(turn.codigo, activeTurn: turn)),
    );
  }

  // ENH-337: Cancelar turno propio
  Future<void> cancelCurrentTurn() async {
    final turnId = state.activeTurn?.id;
    if (turnId == null) return;

    emit(TurnRequestCancelling(activeTurn: state.activeTurn));

    final result = await _repository.cancelTurn(turnId);

    result.fold(
      (failure) => emit(TurnRequestError(failure.message, activeTurn: state.activeTurn)),
      (_) => emit(TurnRequestInitial()), // Volvemos al estado inicial sin turno
    );
  }
}
