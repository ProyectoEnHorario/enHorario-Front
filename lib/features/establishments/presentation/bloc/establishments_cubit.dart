import 'dart:async';

import 'package:enhorario/core/utils/string_normalizer.dart';
import 'package:enhorario/features/establishments/data/models/establishment_model.dart';
import 'package:enhorario/features/establishments/domain/repositories/establishment_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EstablishmentsState {
  const EstablishmentsState({
    this.all = const [],
    this.filtered = const [],
    this.isLoading = true,
    this.error,
    this.query = '',
    this.categoryId,
  });

  final List<EstablishmentModel> all;
  final List<EstablishmentModel> filtered;
  final bool isLoading;
  final String? error;
  final String query;
  final String? categoryId;

  EstablishmentsState copyWith({
    List<EstablishmentModel>? all,
    List<EstablishmentModel>? filtered,
    bool? isLoading,
    String? error,
    bool clearError = false,
    String? query,
    String? categoryId,
    bool clearCategory = false,
  }) {
    return EstablishmentsState(
      all: all ?? this.all,
      filtered: filtered ?? this.filtered,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      query: query ?? this.query,
      categoryId: clearCategory ? null : (categoryId ?? this.categoryId),
    );
  }
}

class EstablishmentsCubit extends Cubit<EstablishmentsState> {
  EstablishmentsCubit(this._repository) : super(const EstablishmentsState()) {
    _subscribe();
  }

  final EstablishmentRepository _repository;
  StreamSubscription<List<EstablishmentModel>>? _subscription;

  Future<void> retrySearch() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    _subscription?.cancel();
    _subscribe();
  }

  void setQuery(String query) {
    emit(_applyFilter(state.copyWith(query: query)));
  }

  void setCategoryFilter(String? categoryId) {
    emit(
      _applyFilter(
        state.copyWith(
          categoryId: categoryId,
          clearCategory: categoryId == null,
        ),
      ),
    );
  }

  Future<String?> create(EstablishmentModel model) async {
    final result = await _repository.create(model);
    return result.fold((l) => l.message, (_) => null);
  }

  Future<String?> update(EstablishmentModel model) async {
    final result = await _repository.update(model);
    return result.fold((l) => l.message, (_) => null);
  }

  Future<String?> delete(String id) async {
    final result = await _repository.delete(id);
    return result.fold((l) => l.message, (_) => null);
  }

  void _subscribe() {
    _subscription = _repository.watchAll().listen(
      (items) {
        final newState = state.copyWith(
          all: items,
          isLoading: false,
          clearError: true,
        );
        emit(_applyFilter(newState));
      },
      onError: (_) => emit(
        state.copyWith(
          isLoading: false,
          error: 'Error cargando establecimientos',
        ),
      ),
    );
  }

  EstablishmentsState _applyFilter(EstablishmentsState value) {
    final query = StringNormalizer.normalize(value.query);
    final filtered = value.all.where((item) {
      final matchesQuery =
          query.isEmpty || item.nombreNormalizado.contains(query);
      final matchesCategory =
          value.categoryId == null || value.categoryId!.isEmpty
          ? true
          : item.categoryId == value.categoryId;
      return matchesQuery && matchesCategory;
    }).toList();
    return value.copyWith(filtered: filtered);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
