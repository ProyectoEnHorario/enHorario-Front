import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';
import 'package:enhorario/features/establishments/domain/repositories/favorites_repository.dart';

class RailwayFavoritesRepository implements FavoritesRepository {
  final ApiClient _apiClient;
  final AuthSessionRepository _sessionRepository;

  RailwayFavoritesRepository(this._apiClient) : _sessionRepository = AuthSessionRepository();

  List<RailwayEstablishmentView>? _cachedDetails;

  @override
  Future<List<String>> getFavorites() async {
    final details = await getFavoritesDetails();
    return details.map((e) => e.id).toList();
  }

  @override
  Future<List<RailwayEstablishmentView>> getFavoritesDetails() async {
    try {
      final userId = await _sessionRepository.getCurrentUserId();
      
      if (userId == null || userId.isEmpty) {
        print('[FavoritesRepo] Error: UserId no encontrado en SharedPreferences');
        throw Exception('Inicia sesión para ver tus favoritos');
      }

      final response = await _apiClient.get<dynamic>(
        '/favorites/my-favorites',
        token: userId,
      );
      
      final items = _extractList(response);
      
      final details = items
          .whereType<Map<String, dynamic>>()
          .map(RailwayEstablishmentView.fromMap)
          .where((item) => item.id.isNotEmpty)
          .toList();

      _cachedDetails = details;
      return details;
    } catch (e) {
      print('[FavoritesRepo] Error en getFavoritesDetails: $e');
      rethrow;
    }
  }

  @override
  Future<void> addFavorite(String id) async {
    try {
      final userId = await _sessionRepository.getCurrentUserId();
      if (userId == null || userId.isEmpty) throw Exception('Sesión expirada');

      await _apiClient.post<void>(
        '/favorites/$id',
        data: {}, // Enviamos {} por compatibilidad con algunos backends
        token: userId,
      );
    } catch (e) {
      print('[FavoritesRepo] Error en addFavorite ($id): $e');
      rethrow;
    }
  }

  @override
  Future<void> removeFavorite(String id) async {
    try {
      final userId = await _sessionRepository.getCurrentUserId();
      if (userId == null || userId.isEmpty) throw Exception('Sesión expirada');

      await _apiClient.delete(
        '/favorites/$id',
        token: userId,
      );
    } catch (e) {
      print('[FavoritesRepo] Error en removeFavorite ($id): $e');
      rethrow;
    }
  }

  List<dynamic> _extractList(dynamic response) {
    if (response is List) return response;
    if (response is Map<String, dynamic>) {
      // Manejo de respuesta paginada tipo { "content": [...] }
      final content = response['content'];
      if (content is List) return content;
    }
    return const [];
  }
}
