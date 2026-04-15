import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';
import 'package:enhorario/features/establishments/domain/repositories/favorites_repository.dart';

class LowAfluenciaService {
  LowAfluenciaService({
    required FavoritesRepository favoritesRepository,
  }) : _favoritesRepository = favoritesRepository;

  final FavoritesRepository _favoritesRepository;

  /// Obtiene los establecimientos favoritos que tienen datos actualizados de afluencia.
  Future<Result<List<RailwayEstablishmentView>>> getFavoritesAfluencia() async {
    try {
      // 1. Obtener detalles de favoritos directamente (una sola peticion al backend)
      final favoritesData = await _favoritesRepository.getFavoritesDetails();
      
      return Right(favoritesData);
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
