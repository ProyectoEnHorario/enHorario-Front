import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/features/turns/data/repositories/railway_turn_repository.dart';

abstract class TurnRequestState {}

class TurnRequestInitial extends TurnRequestState {}
class TurnRequestLoading extends TurnRequestState {}
class TurnRequestSuccess extends TurnRequestState {
  final String ticketCode;
  TurnRequestSuccess(this.ticketCode);
}
class TurnRequestError extends TurnRequestState {
  final String message;
  TurnRequestError(this.message);
}

class TurnRequestCubit extends Cubit<TurnRequestState> {
  final RailwayTurnRepository _repository;

  TurnRequestCubit(this._repository) : super(TurnRequestInitial());

  Future<void> requestTurn({
    required String establishmentId,
    required bool isPriority,
    String? priorityReason,
  }) async {
    emit(TurnRequestLoading());

    final result = await _repository.createTurn(
      establishmentId: establishmentId,
      isPriority: isPriority,
      priorityReason: isPriority ? priorityReason : null,
    );

    result.fold(
      (failure) => emit(TurnRequestError(failure.message)),
      (turn) => emit(TurnRequestSuccess(turn.codigo)),
    );
  }
}
