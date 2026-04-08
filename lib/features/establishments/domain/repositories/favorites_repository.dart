abstract class FavoritesRepository {
  Future<List<String>> getFavorites();
  Future<void> addFavorite(String id);
  Future<void> removeFavorite(String id);
}
