import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/establishments/domain/repositories/favorites_repository.dart';

class RailwayFavoritesRepository implements FavoritesRepository {
  final ApiClient _apiClient;
  
  // ENH-10: Usuario de prueba para el header Authorization
  // ENH-10: Usuario de prueba para el header Authorization (Debe ser un UUID valido para el backend)
  static const _testUserId = '00000000-0000-0000-0000-000000000000';

  RailwayFavoritesRepository(this._apiClient);

  @override
  Future<List<String>> getFavorites() async {
    try {
      final response = await _apiClient.get<List<dynamic>>(
        '/favorites/my-favorites',
        token: _testUserId,
      );
      
      return response
          .map((item) => item['id'].toString())
          .toList();
    } catch (e) {
      // Si hay error en la red o servidor, propagamos para que el Cubit lo maneje
      rethrow;
    }
  }

  @override
  Future<void> addFavorite(String id) async {
    await _apiClient.post<void>(
      '/favorites/$id',
      data: null, // Algunos backends fallan con {} si no esperan body
      token: _testUserId,
    );
  }

  @override
  Future<void> removeFavorite(String id) async {
    await _apiClient.delete(
      '/favorites/$id',
      token: _testUserId,
    );
  }
}
