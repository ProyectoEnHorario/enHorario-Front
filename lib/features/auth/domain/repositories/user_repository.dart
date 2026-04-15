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
}
