import 'package:enhorario/core/utils/string_normalizer.dart';
import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RealEstablishmentsState {
  const RealEstablishmentsState({
    this.all = const [],
    this.filtered = const [],
    this.query = '',
    this.isLoading = true,
    this.error,
  });

  final List<RailwayEstablishmentView> all;
  final List<RailwayEstablishmentView> filtered;
  final String query;
  final bool isLoading;
  final String? error;

  RealEstablishmentsState copyWith({
    List<RailwayEstablishmentView>? all,
    List<RailwayEstablishmentView>? filtered,
    String? query,
    bool? isLoading,
    String? error,
    bool clearError = false,
  }) {
    return RealEstablishmentsState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class RealEstablishmentsCubit extends Cubit<RealEstablishmentsState> {
  RealEstablishmentsCubit(this._service)
      : super(const RealEstablishmentsState()) {
    load();
  }

  final RailwayEstablishmentQueryService _service;

  Future<void> load() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _service.fetchEstablishments();
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          error: failure.message,
          all: const [],
          filtered: const [],
        ),
      ),
      (items) {
        final filtered = _applyFilter(items, state.query);
        emit(
          state.copyWith(
            isLoading: false,
            all: items,
            filtered: filtered,
            clearError: true,
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
        filtered: _applyFilter(state.all, nextQuery),
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
