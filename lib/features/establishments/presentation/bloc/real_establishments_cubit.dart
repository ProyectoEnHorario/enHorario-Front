import 'package:enhorario/core/utils/string_normalizer.dart';
import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RealEstablishmentsState {
  const RealEstablishmentsState({
    this.items = const [],
    this.filtered = const [],
    this.query = '',
    this.isLoading = true,
    this.isRefreshing = false,
    this.error,
    this.lastUpdated,
  });

  final List<RailwayEstablishmentView> items;
  final List<RailwayEstablishmentView> filtered;
  final String query;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final DateTime? lastUpdated;

  RealEstablishmentsState copyWith({
    List<RailwayEstablishmentView>? items,
    List<RailwayEstablishmentView>? filtered,
    String? query,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
    DateTime? lastUpdated,
  }) {
    return RealEstablishmentsState(
      items: items ?? this.items,
      filtered: filtered ?? this.filtered,
      query: query ?? this.query,
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
          filtered: const [],
        ),
      ),
      (items) {
        final filtered = _applyFilter(items, state.query);
        emit(
          state.copyWith(
            isLoading: false,
            items: items,
            filtered: filtered,
            clearError: true,
            lastUpdated: DateTime.now(),
          ),
        );
      },
    );
  }

  Future<void> load() => loadInitial();

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
      (items) {
        final filtered = _applyFilter(items, state.query);
        emit(
          state.copyWith(
            isRefreshing: false,
            items: items,
            filtered: filtered,
            clearError: true,
            lastUpdated: DateTime.now(),
          ),
        );
      },
    );
  }

  void setQuery(String value) {
    final nextQuery = value;
    final normalizedCurrent = StringNormalizer.normalize(state.query);
    final normalizedNext = StringNormalizer.normalize(nextQuery);

    if (normalizedCurrent == normalizedNext) {
      if (state.query != nextQuery) {
        emit(state.copyWith(query: nextQuery));
      }
      return;
    }

    emit(
      state.copyWith(
        query: nextQuery,
        filtered: _applyFilter(state.items, nextQuery),
      ),
    );
  }

  List<RailwayEstablishmentView> _applyFilter(
    List<RailwayEstablishmentView> items,
    String query,
  ) {
    final normalizedQuery = StringNormalizer.normalize(query);
    if (normalizedQuery.isEmpty) return items;

    return items.where((item) {
      final byName = StringNormalizer.normalize(item.name).contains(
        normalizedQuery,
      );
      final byCategory =
          StringNormalizer.normalize(item.categoryName ?? '').contains(
            normalizedQuery,
          );
      final byCity = StringNormalizer.normalize(item.city).contains(
        normalizedQuery,
      );
      return byName || byCategory || byCity;
    }).toList();
  }
}
