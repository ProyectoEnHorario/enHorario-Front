import 'package:enhorario/features/establishments/domain/repositories/favorites_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesState {
  final Set<String> favoriteIds;
  final bool isLoading;
  final String? error;

  const FavoritesState({
    this.favoriteIds = const {},
    this.isLoading = false,
    this.error,
  });

  bool isFavorite(String id) => favoriteIds.contains(id);

  FavoritesState copyWith({
    Set<String>? favoriteIds,
    bool? isLoading,
    String? error,
  }) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
    );
  }
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesCubit(this._repository) : super(const FavoritesState()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    emit(state.copyWith(isLoading: true, error: null));
    try {
      final list = await _repository.getFavorites();
      emit(state.copyWith(favoriteIds: list.toSet(), isLoading: false));
    } catch (e) {
      emit(state.copyWith(
        error: 'No se pudieron cargar los favoritos',
        isLoading: false,
      ));
    }
  }

  Future<void> toggleFavorite(String id) async {
    final isFav = state.favoriteIds.contains(id);
    if (isFav) {
      await removeFavorite(id);
    } else {
      await addFavorite(id);
    }
  }

  Future<void> addFavorite(String id) async {
    if (state.favoriteIds.contains(id)) return;

    final oldFavorites = state.favoriteIds;
    // Optimistic Update
    final newFavorites = Set<String>.from(state.favoriteIds)..add(id);
    emit(state.copyWith(favoriteIds: newFavorites, error: null));

    try {
      await _repository.saveFavorites(newFavorites);
    } catch (e) {
      // Rollback
      emit(state.copyWith(
        favoriteIds: oldFavorites,
        error: 'Error al agregar a favoritos',
      ));
    }
  }

  Future<void> removeFavorite(String id) async {
    if (!state.favoriteIds.contains(id)) return;

    final oldFavorites = state.favoriteIds;
    // Optimistic Update
    final newFavorites = Set<String>.from(state.favoriteIds)..remove(id);
    emit(state.copyWith(favoriteIds: newFavorites, error: null));

    try {
      await _repository.saveFavorites(newFavorites);
    } catch (e) {
      // Rollback
      emit(state.copyWith(
        favoriteIds: oldFavorites,
        error: 'Error al eliminar de favoritos',
      ));
    }
  }
}
