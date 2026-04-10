import 'package:enhorario/features/establishments/domain/repositories/favorites_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LocalFavoritesRepository implements FavoritesRepository {
  static const _key = 'favorite_establishments';

  /// Recupera la lista de IDs de establecimientos marcados como favoritos desde SharedPreferences.
  @override
  Future<List<String>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    // ENH-178: Validar que no se dupliquen favoritos al leerlo de persistencia
    return list.toSet().toList();
  }

  @override
  Future<void> addFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    final set = list.toSet()..add(id);
    await prefs.setStringList(_key, set.toList());
  }

  @override
  Future<void> removeFavorite(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_key) ?? [];
    final set = list.toSet()..remove(id);
    await prefs.setStringList(_key, set.toList());
  }
}
