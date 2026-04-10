import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/establishments/domain/repositories/favorites_repository.dart';

class RailwayFavoritesRepository implements FavoritesRepository {
  final ApiClient _apiClient;
  
  // ENH-10: Usuario de prueba para el header Authorization
  // ENH-10: Usuario de prueba para el header Authorization (Se usa el patron de correo visto en Auth)
  static const _testUserId = 'admin@enhorario.com';

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
      data: {}, // Re-intentamos con {} ya que null tambien dio 400
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
