import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/core/errors/api_exception.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/auth/domain/repositories/login_account_service.dart';

class RailwayLoginAccountService implements LoginAccountService {
  RailwayLoginAccountService(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<Result<LoginAccountSuccess>> login(LoginAccountRequest request) async {
    try {
      final response = await _apiClient.post<dynamic>(
        '/auth/login',
        data: {
          'email': request.email.trim().toLowerCase(),
          'password': request.password,
        },
      );

      if (response is! Map<String, dynamic>) {
        return const Left<Failure, LoginAccountSuccess>(
          Failure('Respuesta invalida del servidor.'),
        );
      }

      final token = response['token']?.toString() ?? '';
      if (token.isEmpty) {
        return const Left<Failure, LoginAccountSuccess>(
          Failure('No fue posible iniciar sesion. Intenta nuevamente.'),
        );
      }

      final role = _extractRole(response);
      final userId = _extractUserId(response);

      return Right<Failure, LoginAccountSuccess>(
        LoginAccountSuccess(
          token: token,
          email: request.email.trim().toLowerCase(),
          role: role,
          userId: userId,
        ),
      );
    } on ApiException catch (e) {
      if (e.statusCode == 400 || e.statusCode == 401) {
        return const Left<Failure, LoginAccountSuccess>(
          Failure('Credenciales invalidas. Verifica tus datos.'),
        );
      }

      if ((e.statusCode ?? 0) >= 500) {
        return const Left<Failure, LoginAccountSuccess>(
          Failure('El servidor no esta disponible en este momento.'),
        );
      }

      return const Left<Failure, LoginAccountSuccess>(
        Failure('Error de conexion. Revisa tu internet e intenta de nuevo.'),
      );
    } catch (_) {
      return const Left<Failure, LoginAccountSuccess>(
        Failure('Error inesperado al iniciar sesion.'),
      );
    }
  }

  String? _extractRole(Map<String, dynamic> payload) {
    final directRole = payload['rol']?.toString() ?? payload['role']?.toString();
    if (directRole != null && directRole.trim().isNotEmpty) {
      return directRole.trim();
    }

    final user = payload['user'];
    if (user is Map<String, dynamic>) {
      final nestedRole = user['rol']?.toString() ?? user['role']?.toString();
      if (nestedRole != null && nestedRole.trim().isNotEmpty) {
        return nestedRole.trim();
      }
    }
    return null;
  }

  String? _extractUserId(Map<String, dynamic> payload) {
    final user = payload['user'];
    if (user is Map<String, dynamic>) {
      final id = user['id']?.toString();
      if (id != null && id.trim().isNotEmpty) {
        return id.trim();
      }
    }
    return null;
  }
}
