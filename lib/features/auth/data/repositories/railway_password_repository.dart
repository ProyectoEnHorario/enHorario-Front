import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/core/errors/api_exception.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:enhorario/features/auth/domain/repositories/password_repository.dart';

class RailwayPasswordRepository implements PasswordRepository {
  RailwayPasswordRepository(this._apiClient);

  final ApiClient _apiClient;
  final _sessionRepository = AuthSessionRepository();

  @override
  Future<Result<String>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final email = await _sessionRepository.getCurrentUserEmail();

      if (email == null || email.isEmpty) {
        return const Left(Failure('No hay una sesión activa.'));
      }

      final body = {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      };

      final response = await _apiClient.patch<Map<String, dynamic>>(
        '/auth/me/password',
        data: body,
        token: email,
      );

      final message = response['message']?.toString() ?? 'Contraseña actualizada con éxito';
      return Right(message);
    } on ApiException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('Error inesperado al cambiar contraseña: $e'));
    }
  }

  @override
  Future<Result<String?>> forgotPassword(String email) async {
    try {
      final body = {'email': email};

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/forgot-password',
        data: body,
      );

      final token = response['resetToken']?.toString();
      return Right(token);
    } on ApiException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('Error inesperado al solicitar recuperación: $e'));
    }
  }

  @override
  Future<Result<String>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmNewPassword,
  }) async {
    try {
      final body = {
        'token': token,
        'newPassword': newPassword,
        'confirmNewPassword': confirmNewPassword,
      };

      final response = await _apiClient.post<Map<String, dynamic>>(
        '/auth/reset-password',
        data: body,
      );

      final message = response['message']?.toString() ?? 'Contraseña restablecida con éxito';
      return Right(message);
    } on ApiException catch (e) {
      return Left(Failure(e.message));
    } catch (e) {
      return Left(Failure('Error inesperado al restablecer contraseña: $e'));
    }
  }
}
