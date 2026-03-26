import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/core/errors/api_exception.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';

class RailwayEstablishmentQueryService {
  RailwayEstablishmentQueryService(this._apiClient);

  final ApiClient _apiClient;

  Future<Result<List<RailwayEstablishmentView>>> fetchEstablishments() async {
    try {
      final response = await _apiClient.get<dynamic>(
        '/establishments',
        queryParameters: {'page': 0, 'size': 50},
      );

      if (response is! Map<String, dynamic>) {
        return const Left<Failure, List<RailwayEstablishmentView>>(
          Failure('Respuesta invalida del servidor.'),
        );
      }

      final content = response['content'];
      if (content is! List) {
        return const Left<Failure, List<RailwayEstablishmentView>>(
          Failure('No se pudo leer la lista de establecimientos.'),
        );
      }

      final items = content
          .whereType<Map<String, dynamic>>()
          .map(RailwayEstablishmentView.fromMap)
          .where((item) => item.id.trim().isNotEmpty)
          .toList(growable: false);

      return Right<Failure, List<RailwayEstablishmentView>>(items);
    } on ApiException catch (_) {
      return const Left<Failure, List<RailwayEstablishmentView>>(
        Failure('No se pudo cargar establecimientos. Intenta nuevamente.'),
      );
    } catch (_) {
      return const Left<Failure, List<RailwayEstablishmentView>>(
        Failure('Ocurrio un error inesperado al consultar establecimientos.'),
      );
    }
  }

  Future<Result<RailwayEstablishmentView>> fetchEstablishmentById(
    String id,
  ) async {
    try {
      final response = await _apiClient.get<dynamic>('/establishments/$id');
      if (response is! Map<String, dynamic>) {
        return const Left<Failure, RailwayEstablishmentView>(
          Failure('No se pudo obtener el detalle del establecimiento.'),
        );
      }
      return Right<Failure, RailwayEstablishmentView>(
        RailwayEstablishmentView.fromMap(response),
      );
    } on ApiException catch (_) {
      return const Left<Failure, RailwayEstablishmentView>(
        Failure('No se pudo consultar el detalle del establecimiento.'),
      );
    } catch (_) {
      return const Left<Failure, RailwayEstablishmentView>(
        Failure('Error inesperado al consultar el detalle.'),
      );
    }
  }
}
