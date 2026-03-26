import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/core/errors/api_exception.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/auth/domain/repositories/register_account_service.dart';

class RailwayRegisterAccountService implements RegisterAccountService {
  RailwayRegisterAccountService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<void>> register(RegisterAccountRequest request) async {
    try {
      await _apiClient.post<dynamic>(
        '/auth/register',
        data: {
          'name': request.nombre,
          'lastName': request.apellido,
          'email': request.email.trim().toLowerCase(),
          'phone': null,
          'password': request.password,
        },
      );

      return const Right<Failure, void>(null);
    } on ApiException catch (e) {
      final message = e.message.toLowerCase();
      if (message.contains('email') || message.contains('correo')) {
        return const Left<Failure, void>(
          Failure('El correo ya esta registrado.'),
        );
      }

      if (e.statusCode == 400) {
        final emailExists = await _emailExists(request.email);
        if (emailExists) {
          return const Left<Failure, void>(
            Failure('El correo ya esta registrado.'),
          );
        }
        return const Left<Failure, void>(
          Failure('No fue posible registrar la cuenta. Verifica los datos.'),
        );
      }

      return const Left<Failure, void>(
        Failure('Error de conexion con el servidor. Intenta nuevamente.'),
      );
    } catch (_) {
      return const Left<Failure, void>(
        Failure('Error inesperado durante el registro.'),
      );
    }
  }

  Future<bool> _emailExists(String email) async {
    try {
      await _apiClient.get<dynamic>(
        '/auth/me',
        token: email.trim().toLowerCase(),
      );
      return true;
    } on ApiException {
      return false;
    } catch (_) {
      return false;
    }
  }
}
