import 'package:enhorario/core/results/result.dart';

abstract class PasswordRepository {
  /// Cambia la contraseña del usuario actualmente autenticado.
  Future<Result<String>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String confirmNewPassword,
  });

  /// Solicita un token temporal para recuperación de contraseña enviando el email.
  Future<Result<String?>> forgotPassword(String email);

  /// Restablece la contraseña usando el token temporal recibido previamente.
  Future<Result<String>> resetPassword({
    required String token,
    required String newPassword,
    required String confirmNewPassword,
  });
}
