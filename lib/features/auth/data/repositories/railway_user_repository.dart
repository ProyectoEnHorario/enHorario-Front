import 'package:dio/dio.dart';
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
      final email = await _sessionRepository.getCurrentUserEmail();

      if (email == null || email.isEmpty) {
        return const Left(Failure('No hay una sesión activa.'));
      }

      final response = await _apiClient.get<Map<String, dynamic>>(
        '/auth/me',
        token: email,
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
    String? profilePhotoPath,
  }) async {
    try {
      final email = await _sessionRepository.getCurrentUserEmail();

      if (email == null || email.isEmpty) {
        return const Left(Failure('No hay una sesión activa.'));
      }

      // Siempre usamos multipart/form-data para compatibilidad con la foto
      final formData = FormData();

      if (name != null && name.isNotEmpty) {
        formData.fields.add(MapEntry('name', name));
      }
      if (lastName != null && lastName.isNotEmpty) {
        formData.fields.add(MapEntry('lastName', lastName));
      }
      if (phone != null && phone.isNotEmpty) {
        formData.fields.add(MapEntry('phone', phone));
      }
      if (profilePhotoPath != null && profilePhotoPath.isNotEmpty) {
        // Extraemos el nombre del archivo para enviarlo correctamente
        final fileName = profilePhotoPath.split('/').last;
        formData.files.add(
          MapEntry(
            'profilePhoto',
            await MultipartFile.fromFile(profilePhotoPath, filename: fileName),
          ),
        );
      }

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/auth/me',
        data: formData,
        token: email,
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
      profilePhotoUrl: response['profilePhotoUrl']?.toString(),
      createdAt: DateTime.tryParse(response['createdAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  @override
  Future<Result<List<AppUser>>> getAllUsers() async {
    try {
      final email = await _sessionRepository.getCurrentUserEmail();
      if (email == null || email.isEmpty) {
        return const Left(Failure('No hay una sesión activa.'));
      }

      final response = await _apiClient.get<dynamic>(
        '/users',
        token: email,
      );

      final List<dynamic> usersList = response is List ? response : response['users'] ?? [];
      
      final users = usersList.map((e) => _mapToUserModel(e as Map<String, dynamic>)).toList();
      return Right(users);
    } on ApiException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('Error inesperado al obtener los usuarios: $e'));
    }
  }

  @override
  Future<Result<String>> updateUserRole(String uid, String newRole) async {
    try {
      final email = await _sessionRepository.getCurrentUserEmail();
      if (email == null || email.isEmpty) {
        return const Left(Failure('No hay una sesión activa.'));
      }

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/users/$uid/role',
        data: {'role': newRole},
        token: email,
      );

      return Right(response['message']?.toString() ?? 'Rol actualizado con éxito');
    } on ApiException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('Error inesperado al actualizar el rol: $e'));
    }
  }

  @override
  Future<Result<String>> deleteUser(String uid) async {
    try {
      final email = await _sessionRepository.getCurrentUserEmail();
      if (email == null || email.isEmpty) {
        return const Left(Failure('No hay una sesión activa.'));
      }

      final response = await _apiClient.delete<Map<String, dynamic>>(
        '/users/$uid',
        token: email,
      );

      return Right(response['message']?.toString() ?? 'Usuario eliminado con éxito');
    } on ApiException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('Error inesperado al eliminar el usuario: $e'));
    }
  }
}
