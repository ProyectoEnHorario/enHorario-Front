import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/auth/domain/entities/app_user.dart';

abstract class UserRepository {
  Future<Result<AppUser>> getUserProfile();
  
  Future<Result<AppUser>> updateProfile({
    String? name,
    String? lastName,
    String? phone,
    String? profilePhotoPath, // ruta local del archivo de imagen
  });

  /// [SUPERADMIN] Obtiene la lista de todos los usuarios registrados. Soporta búsqueda por nombre o correo.
  Future<Result<List<AppUser>>> getAllUsers([String? query]);

  /// [SUPERADMIN] Cambia el rol de un usuario (ej. a 'superadmin' o 'usuario').
  Future<Result<String>> updateUserRole(String uid, String newRole);

  /// [SUPERADMIN] Elimina la cuenta de un usuario (Soft Delete o Hard Delete).
  Future<Result<String>> deleteUser(String uid);
}
