import 'dart:async';

import 'package:enhorario/features/turns/data/models/turn_model.dart';
import 'package:enhorario/features/turns/domain/repositories/turn_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TurnsState {
  const TurnsState({
    this.items = const [],
    this.establishmentId = '',
    this.isLoading = false,
    this.error,
  });

  final List<TurnModel> items;
  final String establishmentId;
  final bool isLoading;
  final String? error;

  TurnsState copyWith({
    List<TurnModel>? items,
    String? establishmentId,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return TurnsState(
      items: items ?? this.items,
      establishmentId: establishmentId ?? this.establishmentId,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class TurnsCubit extends Cubit<TurnsState> {
  TurnsCubit(this._repository) : super(const TurnsState());

  final TurnRepository _repository;
  StreamSubscription<List<TurnModel>>? _subscription;

  void listen(String establishmentId) {
    _subscription?.cancel();
    emit(
      state.copyWith(
        isLoading: true,
        establishmentId: establishmentId,
        clearError: true,
      ),
    );
    _subscription = _repository
        .watchByEstablishment(establishmentId)
        .listen(
          (items) => emit(
            state.copyWith(items: items, isLoading: false, clearError: true),
          ),
          onError: (_) => emit(
            state.copyWith(isLoading: false, error: 'Error al cargar turnos'),
          ),
        );
  }

  Future<String?> createTurn(String tipo) async {
    if (state.establishmentId.isEmpty) {
      return 'Ingresa establishmentId';
    }
    final result = await _repository.createTurn(
      establishmentId: state.establishmentId,
      tipo: tipo,
    );
    return result.fold((l) => l.message, (_) => null);
  }

  Future<String?> advanceTurn(TurnModel turn) async {
    final next = switch (turn.estado) {
      'en_espera' => 'en_atencion',
      'en_atencion' => 'atendido',
      _ => turn.estado,
    };
    final result = await _repository.updateStatus(
      establishmentId: state.establishmentId,
      turnId: turn.id,
      estado: next,
    );
    return result.fold((l) => l.message, (_) => null);
  }

  Future<String?> cancelTurn(TurnModel turn) async {
    final result = await _repository.cancelTurn(
      establishmentId: state.establishmentId,
      turnId: turn.id,
    );
    return result.fold((l) => l.message, (_) => null);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
