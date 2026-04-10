import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:enhorario/features/establishments/domain/repositories/favorites_repository.dart';

class RailwayFavoritesRepository implements FavoritesRepository {
  final ApiClient _apiClient;
  final AuthSessionRepository _sessionRepository;

  RailwayFavoritesRepository(this._apiClient) : _sessionRepository = AuthSessionRepository();

  @override
  Future<List<String>> getFavorites() async {
    try {
      final token = await _sessionRepository.getAuthToken();
      final response = await _apiClient.get<List<dynamic>>(
        '/favorites/my-favorites',
        token: token,
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
    final token = await _sessionRepository.getAuthToken();
    await _apiClient.post<void>(
      '/favorites/$id',
      data: null, // El endpoint no requiere body segun curl -X POST
      token: token,
    );
  }

  @override
  Future<void> removeFavorite(String id) async {
    final token = await _sessionRepository.getAuthToken();
    await _apiClient.delete(
      '/favorites/$id',
      token: token,
    );
  }
}
