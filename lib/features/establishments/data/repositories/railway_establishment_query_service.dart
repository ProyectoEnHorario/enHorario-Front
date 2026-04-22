import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/core/errors/api_exception.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';
import 'package:enhorario/features/establishments/data/models/wait_time_report_model.dart';

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
        queryParameters: {'page': page, 'size': size},
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
        return Left<Failure, List<RailwayEstablishmentView>>(
          Failure('El servidor no esta disponible en este momento.', statusCode: e.statusCode),
        );
      }
      if (e.message.toLowerCase().contains('application not found')) {
        return Left<Failure, List<RailwayEstablishmentView>>(
          Failure(
            'No fue posible conectar con el backend configurado. Verifica BACKEND_URL o el despliegue de Railway.',
            statusCode: e.statusCode,
          ),
        );
      }
      return Left<Failure, List<RailwayEstablishmentView>>(
        Failure(
          'No fue posible consultar establecimientos. Detalle: ${e.message}',
          statusCode: e.statusCode,
        ),
      );
    } catch (_) {
      return const Left<Failure, List<RailwayEstablishmentView>>(
        Failure('Error inesperado al consultar establecimientos.'),
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
          Failure('Respuesta invalida del servidor.'),
        );
      }

      return Right<Failure, RailwayEstablishmentView>(
        RailwayEstablishmentView.fromMap(response),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 404) {
        return Left<Failure, RailwayEstablishmentView>(
          Failure('No se encontro el establecimiento solicitado.', statusCode: 404),
        );
      }
      if ((e.statusCode ?? 0) >= 500) {
        return Left<Failure, RailwayEstablishmentView>(
          Failure('El servidor no esta disponible en este momento.', statusCode: e.statusCode),
        );
      }
      return Left<Failure, RailwayEstablishmentView>(
        Failure('No fue posible consultar el tiempo de espera.', statusCode: e.statusCode),
      );
    } catch (_) {
      return const Left<Failure, RailwayEstablishmentView>(
        Failure('Error inesperado al consultar el establecimiento.'),
      );
    }
  }

  Future<Result<void>> reportWaitTime(
    String establishmentId,
    WaitTimeReportModel model,
  ) async {
    // SIMULACIÓN: El backend aún no tiene este endpoint (404),
    // así que simulamos éxito para completar el flujo de la UI.
    await Future.delayed(const Duration(milliseconds: 1500));
    return const Right(null);

    /* 
    // Código para cuando el Backend esté listo:
    try {
      await _apiClient.post<dynamic>(
        '/establishments/$establishmentId/wait-time',
        data: model.toMap(),
      );
      return const Right(null);
    } on ApiException catch (e) {
      if ((e.statusCode ?? 0) >= 500) {
        return Left(Failure('El servidor no está disponible.', statusCode: e.statusCode));
      }
      return Left(Failure('Error: ${e.message}', statusCode: e.statusCode));
    } catch (_) {
      return const Left(Failure('Error inesperado al enviar el reporte.'));
    }
    */
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
