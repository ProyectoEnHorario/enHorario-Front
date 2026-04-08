import 'package:enhorario/features/establishments/domain/repositories/favorites_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoritesState {
  final Set<String> favoriteIds;

  const FavoritesState({
    this.favoriteIds = const {},
  });

  FavoritesState copyWith({
    Set<String>? favoriteIds,
  }) {
    return FavoritesState(
      favoriteIds: favoriteIds ?? this.favoriteIds,
    );
  }
}

class FavoritesCubit extends Cubit<FavoritesState> {
  final FavoritesRepository _repository;

  FavoritesCubit(this._repository) : super(const FavoritesState()) {
    loadFavorites();
  }

  Future<void> loadFavorites() async {
    final list = await _repository.getFavorites();
    emit(state.copyWith(favoriteIds: list.toSet()));
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
    
    // Optimistic Update
    final newFavorites = Set<String>.from(state.favoriteIds)..add(id);
    emit(state.copyWith(favoriteIds: newFavorites));
    
    await _repository.addFavorite(id);
  }

  Future<void> removeFavorite(String id) async {
    if (!state.favoriteIds.contains(id)) return;

    // Optimistic Update
    final newFavorites = Set<String>.from(state.favoriteIds)..remove(id);
    emit(state.copyWith(favoriteIds: newFavorites));
    
    await _repository.removeFavorite(id);
  }

  bool isFavorite(String id) {
    return state.favoriteIds.contains(id);
  }
}
