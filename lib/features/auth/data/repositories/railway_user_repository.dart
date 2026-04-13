import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/core/errors/api_exception.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/auth/data/models/app_user_model.dart';
import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:enhorario/features/auth/domain/entities/app_user.dart';
import 'package:enhorario/features/auth/domain/repositories/user_repository.dart';

class RailwayUserRepository implements UserRepository {
  RailwayUserRepository(this._apiClient);

  final ApiClient _apiClient;
  final _sessionRepository = AuthSessionRepository();

  @override
  Future<Result<AppUser>> getUserProfile() async {
    try {
      final token = await _sessionRepository.getAuthToken();
      
      if (token == null || token.isEmpty) {
        return const Left(Failure('No hay una sesión activa.'));
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/auth/me',
        token: token,
      );

      final user = AppUserModel(
        uid: response['id']?.toString() ?? '',
        email: response['email']?.toString() ?? '',
        nombre: response['name']?.toString() ?? '',
        apellido: response['lastName']?.toString() ?? '',
        rol: response['role']?.toString() ?? 'usuario',
        telefono: response['phone']?.toString(),
        createdAt: DateTime.tryParse(response['createdAt']?.toString() ?? '') ?? DateTime.now(),
      );

      return Right(user);
    } on ApiException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('Error inesperado al cargar el perfil: $e'));
    }
  }
}
