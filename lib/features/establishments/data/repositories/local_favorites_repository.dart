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
  Future<void> saveFavorites(Set<String> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(_key, favorites.toList());
  }
}
