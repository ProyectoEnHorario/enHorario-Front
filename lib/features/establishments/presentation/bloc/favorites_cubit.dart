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
    
    // Actualización optimista de la UI
    final newFavorites = Set<String>.from(state.favoriteIds);
    if (isFav) {
      newFavorites.remove(id);
      emit(state.copyWith(favoriteIds: newFavorites));
      await _repository.removeFavorite(id);
    } else {
      newFavorites.add(id);
      emit(state.copyWith(favoriteIds: newFavorites));
      await _repository.addFavorite(id);
    }
  }

  bool isFavorite(String id) {
    return state.favoriteIds.contains(id);
  }
}
