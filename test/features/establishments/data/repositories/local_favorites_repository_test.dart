import 'package:enhorario/features/establishments/data/repositories/local_favorites_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  group('LocalFavoritesRepository Persistence Test (ENH-179)', () {
    late LocalFavoritesRepository repository;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      repository = LocalFavoritesRepository();
    });

    test('should persist favorites between different repository instances', () async {
      const initialFavorites = ['est_1', 'est_2'];
      
      // 1. Guardar favoritos en la primera instancia
      await repository.addFavorite(initialFavorites[0]);
      await repository.addFavorite(initialFavorites[1]);

      // 2. Simular "reinicio" creando una nueva instancia del repositorio
      final newRepository = LocalFavoritesRepository();
      
      // 3. Recuperar favoritos
      final savedFavorites = await newRepository.getFavorites();

      // 4. Verificar que se mantienen
      expect(savedFavorites, containsAll(initialFavorites));
      expect(savedFavorites.length, equals(initialFavorites.length));
    });

    test('should handle empty favorites on cold start', () async {
      final favorites = await repository.getFavorites();
      expect(favorites, isEmpty);
    });
  });
}
