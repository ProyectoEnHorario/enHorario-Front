import 'dart:async';

import 'package:enhorario/features/wait_times/data/models/wait_time_model.dart';
import 'package:enhorario/features/wait_times/domain/repositories/wait_time_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WaitTimesState {
  const WaitTimesState({
    this.item,
    this.establishmentId = '',
    this.isLoading = false,
    this.error,
  });

  final WaitTimeModel? item;
  final String establishmentId;
  final bool isLoading;
  final String? error;

  WaitTimesState copyWith({
    WaitTimeModel? item,
    bool clearItem = false,
    String? establishmentId,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return WaitTimesState(
      item: clearItem ? null : (item ?? this.item),
      establishmentId: establishmentId ?? this.establishmentId,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class WaitTimesCubit extends Cubit<WaitTimesState> {
  WaitTimesCubit(this._repository) : super(const WaitTimesState());

  final WaitTimeRepository _repository;
  StreamSubscription<WaitTimeModel?>? _subscription;

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
          (item) => emit(
            state.copyWith(item: item, isLoading: false, clearError: true),
          ),
          onError: (_) => emit(
            state.copyWith(
              isLoading: false,
              error: 'Error al cargar tiempo de espera',
            ),
          ),
        );
  }

  Future<String?> saveMinutes(int minutes) async {
    if (state.establishmentId.isEmpty) return 'Ingresa establishmentId';
    final model = WaitTimeModel(
      id: state.establishmentId,
      establishmentId: state.establishmentId,
      minutos: minutes,
      actualizadoEn: DateTime.now(),
    );
    final result = await _repository.upsert(model);
    return result.fold((l) => l.message, (_) => null);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
