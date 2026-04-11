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

      // 2. Consultar cada favorito por ID para evitar depender de paginación
      final futures = favoriteIds
          .map((id) => _queryService.fetchEstablishmentById(id));
      final results = await Future.wait(futures);

      final establishments = <RailwayEstablishmentView>[];
      for (final result in results) {
        result.fold(
          (_) {}, // Ignorar errores individuales (ej. establecimiento eliminado)
          establishments.add,
        );
      }

      return Right(establishments);
    } catch (e) {
      return Left(Failure('Error al consultar datos de afluencia: $e'));
    }
  }

  /// Detecta cuáles establecimientos favoritos tienen actualmente baja afluencia.
  Future<Result<List<RailwayEstablishmentView>>> getLowAfluenciaAlerts() async {
    final result = await getFavoritesAfluencia();

    return result.fold(
      (failure) => Left(failure),
      (favorites) {
        // Filtramos solo los establecimientos que están abiertos y tienen nivel 1 (Baja)
        final lowAfluenciaItems = favorites
            .where((e) => e.isOpen && e.occupancyLevel == 1)
            .toList();

        return Right(lowAfluenciaItems);
      },
    );
  }
}
