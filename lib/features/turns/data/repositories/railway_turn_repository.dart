import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/core/errors/api_exception.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/turns/data/models/turn_model.dart';

class RailwayTurnRepository {
  final ApiClient _apiClient;

  RailwayTurnRepository(this._apiClient);

  Future<Result<List<TurnModel>>> fetchDailyTurns({
    required String establishmentId,
    required DateTime date,
  }) async {
    try {
      // Formateamos la fecha a YYYY-MM-DD para la consulta
      final dateStr = date.toIso8601String().split('T')[0];
      
      final response = await _apiClient.get<dynamic>(
        '/establishments/$establishmentId/turns',
        queryParameters: {'date': dateStr},
      );

      if (response is! List) {
        return const Left(Failure('Respuesta del servidor inválida.'));
      }

      final turns = response
          .map((item) => TurnModel.fromMap(item as Map<String, dynamic>, id: item['id'] ?? ''))
          .toList();

      return Right(turns);
    } on ApiException catch (e) {
      return Left(Failure('Error al consultar turnos: ${e.message}', statusCode: e.statusCode));
    } catch (e) {
      return const Left(Failure('Error inesperado al obtener los turnos del día.'));
    }
  }
}
