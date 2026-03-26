import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/core/errors/api_exception.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';

class RailwayEstablishmentQueryService {
  RailwayEstablishmentQueryService(this._apiClient);

  final ApiClient _apiClient;

  Future<Result<List<RailwayEstablishmentView>>> fetchEstablishments({
    int page = 0,
    int size = 30,
  }) async {
    try {
      final response = await _apiClient.get<dynamic>(
        '/establishments',
        queryParameters: {
          'page': page,
          'size': size,
        },
      );

      final content = _extractContent(response);
      final items = content
          .whereType<Map<String, dynamic>>()
          .map(RailwayEstablishmentView.fromMap)
          .where((item) => item.id.isNotEmpty)
          .toList();

      return Right<Failure, List<RailwayEstablishmentView>>(items);
    } on ApiException catch (e) {
      if ((e.statusCode ?? 0) >= 500) {
        return const Left<Failure, List<RailwayEstablishmentView>>(
          Failure('El servidor no esta disponible en este momento.'),
        );
      }
      return const Left<Failure, List<RailwayEstablishmentView>>(
        Failure('No fue posible consultar establecimientos.'),
      );
    } catch (_) {
      return const Left<Failure, List<RailwayEstablishmentView>>(
        Failure('Error inesperado al consultar establecimientos.'),
      );
    }
  }

  Future<Result<RailwayEstablishmentView>> fetchEstablishmentById(String id) async {
    try {
      final response = await _apiClient.get<dynamic>('/establishments/$id');
      if (response is! Map<String, dynamic>) {
        return const Left<Failure, RailwayEstablishmentView>(
          Failure('Respuesta invalida del servidor.'),
        );
      }

      return Right<Failure, RailwayEstablishmentView>(
        RailwayEstablishmentView.fromMap(response),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return const Left<Failure, RailwayEstablishmentView>(
          Failure('No se encontro el establecimiento solicitado.'),
        );
      }
      if ((e.statusCode ?? 0) >= 500) {
        return const Left<Failure, RailwayEstablishmentView>(
          Failure('El servidor no esta disponible en este momento.'),
        );
      }
      return const Left<Failure, RailwayEstablishmentView>(
        Failure('No fue posible consultar el tiempo de espera.'),
      );
    } catch (_) {
      return const Left<Failure, RailwayEstablishmentView>(
        Failure('Error inesperado al consultar el establecimiento.'),
      );
    }
  }

  List<dynamic> _extractContent(dynamic response) {
    if (response is List) {
      return response;
    }
    if (response is Map<String, dynamic>) {
      final content = response['content'];
      if (content is List) {
        return content;
      }
    }
    return const [];
  }
}
