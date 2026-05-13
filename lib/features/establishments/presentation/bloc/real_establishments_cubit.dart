import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';
import 'package:enhorario/features/establishments/domain/filters/establishment_filter_logic.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RealEstablishmentsState {
  const RealEstablishmentsState({
    this.items = const [],
    this.filtered = const [],
    this.availableCategories = const [],
    this.selectedCategoryKeys = const [],
    this.query = '',
    this.isLoading = true,
    this.isRefreshing = false,
    this.error,
    this.lastUpdated,
    this.adminId,
  });

  final List<RailwayEstablishmentView> items;
  final List<RailwayEstablishmentView> filtered;
  final List<EstablishmentCategoryOption> availableCategories;
  final List<String> selectedCategoryKeys;
  final String query;
  final bool isLoading;
  final bool isRefreshing;
  final String? error;
  final DateTime? lastUpdated;
  final String? adminId;

  bool get hasActiveFilters => query.trim().isNotEmpty || selectedCategoryKeys.isNotEmpty;

  RealEstablishmentsState copyWith({
    List<RailwayEstablishmentView>? items,
    List<RailwayEstablishmentView>? filtered,
    List<EstablishmentCategoryOption>? availableCategories,
    List<String>? selectedCategoryKeys,
    String? query,
    bool? isLoading,
    bool? isRefreshing,
    String? error,
    bool clearError = false,
    DateTime? lastUpdated,
    String? adminId,
  }) {
    return RealEstablishmentsState(
      items: items ?? this.items,
      filtered: filtered ?? this.filtered,
      availableCategories: availableCategories ?? this.availableCategories,
      selectedCategoryKeys: selectedCategoryKeys ?? this.selectedCategoryKeys,
      query: query ?? this.query,
      isLoading: isLoading ?? this.isLoading,
      isRefreshing: isRefreshing ?? this.isRefreshing,
      error: clearError ? null : (error ?? this.error),
      lastUpdated: lastUpdated ?? this.lastUpdated,
      adminId: adminId ?? this.adminId,
    );
  }
}

class RealEstablishmentsCubit extends Cubit<RealEstablishmentsState> {
  RealEstablishmentsCubit(this._service)
      : super(const RealEstablishmentsState());

  final RailwayEstablishmentQueryService _service;

  Future<void> loadInitial({String? adminId}) async {
    emit(
      state.copyWith(
        isLoading: true,
        isRefreshing: false,
        clearError: true,
        adminId: adminId,
      ),
    );

    final result = await _service.fetchEstablishments(adminId: adminId);
    result.fold(
      (failure) => emit(
        state.copyWith(
          isLoading: false,
          error: failure.message,
          items: const [],
          filtered: const [],
          availableCategories: const [],
          selectedCategoryKeys: const [],
        ),
      ),
      (items) {
        final categories = EstablishmentFilterLogic.buildCategoryOptions(items);
        final filtered = EstablishmentFilterLogic.applyFilters(
          items,
          query: state.query,
          selectedCategoryKeys: state.selectedCategoryKeys.toSet(),
        );
        emit(
          state.copyWith(
            isLoading: false,
            items: items,
            filtered: filtered,
            availableCategories: categories,
            clearError: true,
            lastUpdated: DateTime.now(),
          ),
        );
      },
    );
  }

  Future<void> load({String? adminId}) => loadInitial(adminId: adminId);

  Future<void> refreshTimes() async {
    if (state.isRefreshing) return;

    emit(state.copyWith(isRefreshing: true, clearError: true));
    final result = await _service.fetchEstablishments(adminId: state.adminId);

    result.fold(
      (failure) => emit(
        state.copyWith(
          isRefreshing: false,
          error: failure.message,
        ),
      ),
      (items) {
        final categories = EstablishmentFilterLogic.buildCategoryOptions(items);
        final filtered = EstablishmentFilterLogic.applyFilters(
          items,
          query: state.query,
          selectedCategoryKeys: state.selectedCategoryKeys.toSet(),
        );
        emit(
          state.copyWith(
            isRefreshing: false,
            items: items,
            filtered: filtered,
            availableCategories: categories,
            clearError: true,
            lastUpdated: DateTime.now(),
          ),
        );
      },
    );
  }

  void setQuery(String value) {
    emit(
      state.copyWith(
        query: value,
        filtered: EstablishmentFilterLogic.applyFilters(
          state.items,
          query: value,
          selectedCategoryKeys: state.selectedCategoryKeys.toSet(),
        ),
      ),
    );
  }

  void toggleCategory(String categoryKey) {
    final selected = {...state.selectedCategoryKeys};
    if (selected.contains(categoryKey)) {
      selected.remove(categoryKey);
    } else {
      selected.add(categoryKey);
    }

    emit(
      state.copyWith(
        selectedCategoryKeys: selected.toList(),
        filtered: EstablishmentFilterLogic.applyFilters(
          state.items,
          query: state.query,
          selectedCategoryKeys: selected,
        ),
      ),
    );
  }

  void clearCategoryFilters() {
    emit(
      state.copyWith(
        selectedCategoryKeys: const [],
        filtered: EstablishmentFilterLogic.applyFilters(
          state.items,
          query: state.query,
          selectedCategoryKeys: const <String>{},
        ),
      ),
    );
  }

  void clearAllFilters() {
    emit(
      state.copyWith(
        query: '',
        selectedCategoryKeys: const [],
        filtered: state.items,
      ),
    );
  }
}
