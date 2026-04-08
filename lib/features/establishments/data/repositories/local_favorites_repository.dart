import 'package:enhorario/features/establishments/domain/repositories/favorites_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalFavoritesRepository implements FavoritesRepository {
  static const _key = 'favorite_establishments';

  @override
  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_key) ?? [];
  }

  @override
  Future<void> addFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (!list.contains(id)) {
      list.add(id);
      await prefs.setStringList(_key, list);
    }
  }

  @override
  Future<void> removeFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    if (list.contains(id)) {
      list.remove(id);
      await prefs.setStringList(_key, list);
    }
  }
}
