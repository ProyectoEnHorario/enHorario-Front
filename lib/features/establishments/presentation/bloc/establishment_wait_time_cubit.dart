import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EstablishmentWaitTimeState {
  const EstablishmentWaitTimeState({
    this.item,
    this.isLoading = true,
    this.isRefreshing = false,
    this.error,
    this.lastUpdated,
  });

  final RailwayEstablishmentView? item;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final DateTime? lastUpdated;

  EstablishmentWaitTimeState copyWith({
    RailwayEstablishmentView? item,
    bool clearItem = false,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return EstablishmentWaitTimeState(
      item: clearItem ? null : (item ?? this.item),
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class EstablishmentWaitTimeCubit extends Cubit<EstablishmentWaitTimeState> {
  EstablishmentWaitTimeCubit(this._service)
      : super(const EstablishmentWaitTimeState());

  final RailwayEstablishmentQueryService _service;

  Future<void> load(String establishmentId) async {
    emit(
      state.copyWith(
        isLoading: true,
        isRefreshing: false,
        clearError: true,
      ),
    );

    final result = await _service.fetchEstablishmentById(establishmentId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          error: failure.message,
          clearItem: true,
        ),
      ),
      (item) => emit(
        state.copyWith(
          isLoading: false,
          item: item,
          clearError: true,
          lastUpdated: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> refresh(String establishmentId) async {
    if (state.isRefreshing) return;

    emit(state.copyWith(isRefreshing: true, clearError: true));
    final result = await _service.fetchEstablishmentById(establishmentId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isRefreshing: false,
          error: failure.message,
        ),
      ),
      (item) {
        final previous = state.item;
        final sameData = previous != null &&
            previous.id == item.id &&
            previous.status == item.status &&
            previous.averageWaitMinutes == item.averageWaitMinutes &&
            previous.updatedAt == item.updatedAt;

        if (sameData) {
          emit(
            state.copyWith(
              isRefreshing: false,
              clearError: true,
              lastUpdated: DateTime.now(),
            ),
          );
          return;
        }

        emit(
          state.copyWith(
            isRefreshing: false,
            item: item,
            clearError: true,
            lastUpdated: DateTime.now(),
          ),
        );
      },
    );
  }
}
