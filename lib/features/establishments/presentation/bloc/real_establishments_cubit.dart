import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RealEstablishmentsState {
  const RealEstablishmentsState({
    this.items = const [],
    this.isLoading = true,
    this.isRefreshing = false,
    this.error,
    this.lastUpdated,
  });

  final List<RailwayEstablishmentView> items;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final DateTime? lastUpdated;

  RealEstablishmentsState copyWith({
    List<RailwayEstablishmentView>? items,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return RealEstablishmentsState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }
}

class RealEstablishmentsCubit extends Cubit<RealEstablishmentsState> {
  RealEstablishmentsCubit(this._service)
      : super(const RealEstablishmentsState()) {
    loadInitial();
  }

  final RailwayEstablishmentQueryService _service;

  Future<void> loadInitial() async {
    emit(
      state.copyWith(
        isLoading: true,
        isRefreshing: false,
        clearError: true,
      ),
    );

    final result = await _service.fetchEstablishments();
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          error: failure.message,
          items: const [],
        ),
      ),
      (items) => emit(
        state.copyWith(
          isLoading: false,
          items: items,
          clearError: true,
          lastUpdated: DateTime.now(),
        ),
      ),
    );
  }

  Future<void> refreshTimes() async {
    if (state.isRefreshing) return;

    emit(state.copyWith(isRefreshing: true, clearError: true));
    final result = await _service.fetchEstablishments();

    result.fold(
      (failure) => emit(
        state.copyWith(
          isRefreshing: false,
          error: failure.message,
        ),
      ),
      (items) => emit(
        state.copyWith(
          isRefreshing: false,
          items: items,
          clearError: true,
          lastUpdated: DateTime.now(),
        ),
      ),
    );
  }
}
