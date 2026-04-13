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
      // Nota: Según la especificación del backend actual, se usa el email como token.
      final email = await _sessionRepository.getCurrentUserEmail();
      
      if (email == null || email.isEmpty) {
        return const Left(Failure('No hay una sesión activa.'));
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/auth/me',
        token: email, // Usamos el email como indica la especificación
      );

      return Right(_mapToUserModel(response));
    } on ApiException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('Error inesperado al cargar el perfil: $e'));
    }
  }

  @override
  Future<Result<AppUser>> updateProfile({
    String? name,
    String? lastName,
    String? phone,
    String? profilePhotoUrl,
  }) async {
    try {
      final email = await _sessionRepository.getCurrentUserEmail();
      
      if (email == null || email.isEmpty) {
        return const Left(Failure('No hay una sesión activa.'));
      }

      final Map<String, dynamic> data = {};
      if (name != null) data['name'] = name;
      if (lastName != null) data['lastName'] = lastName;
      if (phone != null) data['phone'] = phone;
      if (profilePhotoUrl != null) data['profilePhotoUrl'] = profilePhotoUrl;

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/auth/me',
        data: data,
        token: email, // Usamos el email como indica la especificación
      );

      return Right(_mapToUserModel(response));
    } on ApiException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('Error inesperado al actualizar el perfil: $e'));
    }
  }

  AppUserModel _mapToUserModel(Map<String, dynamic> response) {
    return AppUserModel(
      uid: response['id']?.toString() ?? '',
      email: response['email']?.toString() ?? '',
      nombre: response['name']?.toString() ?? '',
      apellido: response['lastName']?.toString() ?? '',
      rol: response['role']?.toString() ?? 'usuario',
      telefono: response['phone']?.toString(),
      createdAt: DateTime.tryParse(response['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }
}
