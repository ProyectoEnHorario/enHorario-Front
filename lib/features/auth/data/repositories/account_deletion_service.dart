import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/core/errors/api_exception.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';

class AccountDeletionService {
  AccountDeletionService(this._apiClient);

  final ApiClient _apiClient;

  /// Eliminar la cuenta del usuario autenticado
  /// 
  /// Hace una solicitud DELETE al endpoint /users/me del servidor
  /// Si es exitosa, retorna Right (éxito)
  /// Si hay error, retorna Left con el error
  Future<Result<void>> deleteCurrentUserAccount() async {
    try {
      await _apiClient.delete('/users/me');
      return const Right<Failure, void>(null);
    } on ApiException catch (e) {
      String message = e.message;
      
      if (e.statusCode == 401) {
        message = 'Sesión expirada. Por favor, inicia sesión nuevamente.';
      } else if (e.statusCode == 404) {
        message = 'Cuenta no encontrada.';
      } else if (e.statusCode == 500) {
        message = 'Error del servidor. Intenta más tarde.';
      }
      
      return Left<Failure, void>(
        Failure(message),
      );
    } catch (e) {
      return Left<Failure, void>(
        Failure('Error inesperado: $e'),
      );
    }
  }
}
