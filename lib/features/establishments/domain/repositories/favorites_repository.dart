abstract class FavoritesRepository {
  Future<List<String>> getFavorites();
  Future<void> saveFavorites(Set<String> favorites);
}
