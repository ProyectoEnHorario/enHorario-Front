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
    _loadSearchResults();
  }

  final EstablishmentRepository _repository;
  Timer? _searchDebounce;

  void setQuery(String rawInput) {
    final query = _captureSearchInput(rawInput);
    emit(state.copyWith(query: query));
    _scheduleSearch();
  }

  void setCategoryFilter(String? categoryId) {
    final normalizedCategory = _captureCategoryInput(categoryId);
    emit(
      state.copyWith(
        categoryId: normalizedCategory,
        clearCategory: normalizedCategory == null,
      ),
    );
    _scheduleSearch();
  }

  Future<void> retrySearch() {
    return _loadSearchResults();
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

  void _scheduleSearch() {
    _searchDebounce?.cancel();
    _searchDebounce = Timer(
      const Duration(milliseconds: 250),
      _loadSearchResults,
    );
  }

  Future<void> _loadSearchResults() async {
    emit(state.copyWith(isLoading: true, clearError: true));
    final result = await _repository.fetchForSearch();
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          error: _mapSearchError(failure.message),
          filtered: const [],
        ),
      ),
      (items) {
        final filtered = _filterItems(
          items: items,
          query: state.query,
          categoryId: state.categoryId,
        );
        emit(
          state.copyWith(
            all: items,
            filtered: filtered,
            isLoading: false,
            clearError: true,
          ),
        );
      },
    );
  }

  String _captureSearchInput(String input) {
    final trimmed = input.trim();
    return trimmed.isEmpty ? '' : input;
  }

  String? _captureCategoryInput(String? value) {
    if (value == null) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  List<EstablishmentModel> _filterItems({
    required List<EstablishmentModel> items,
    required String query,
    String? categoryId,
  }) {
    final normalizedQuery = StringNormalizer.normalize(query);
    return items.where((item) {
      final normalizedName = item.nombreNormalizado.isNotEmpty
          ? item.nombreNormalizado
          : StringNormalizer.normalize(item.nombre);
      final matchesQuery =
          normalizedQuery.isEmpty || normalizedName.contains(normalizedQuery);
      final matchesCategory = categoryId == null
          ? true
          : item.categoryId == categoryId;
      return matchesQuery && matchesCategory;
    }).toList();
  }

  String _mapSearchError(String original) {
    if (original.toLowerCase().contains('permission')) {
      return 'No fue posible buscar establecimientos por permisos insuficientes.';
    }
    return 'No fue posible obtener resultados. Revisa tu conexión e intenta de nuevo.';
  }

  @override
  Future<void> close() {
    _searchDebounce?.cancel();
    return super.close();
  }
}
