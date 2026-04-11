import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:enhorario/features/establishments/domain/repositories/favorites_repository.dart';

class LowAfluenciaService {
  LowAfluenciaService({
    required FavoritesRepository favoritesRepository,
    required RailwayEstablishmentQueryService queryService,
  }) : _favoritesRepository = favoritesRepository,
       _queryService = queryService;

  final FavoritesRepository _favoritesRepository;
  final RailwayEstablishmentQueryService _queryService;

  /// Obtiene los establecimientos favoritos que tienen datos actualizados de afluencia.
  Future<Result<List<RailwayEstablishmentView>>> getFavoritesAfluencia() async {
    try {
      // 1. Obtener IDs de favoritos
      final favoriteIds = await _favoritesRepository.getFavorites();
      
      if (favoriteIds.isEmpty) {
        return const Right([]);
      }

      // 2. Obtener todos los establecimientos desde la API
      // Nota: En una API real idealmente filtraríamos por IDs, 
      // pero usamos la infraestructura existente.
      final result = await _queryService.fetchEstablishments();

      return result.fold(
        (failure) => Left(failure),
        (allEstablishments) {
          // 3. Filtrar solo los que son favoritos
          final favoritesData = allEstablishments
              .where((e) => favoriteIds.contains(e.id))
              .toList();
          
          return Right(favoritesData);
        },
      );
    } catch (e) {
      return Left(Failure('Error al consultar datos de afluencia: $e'));
    }
  }
}
