import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/auth/domain/entities/app_user.dart';

abstract class AuthRepository {
  Stream<AppUser?> authState();

  Future<Result<AppUser>> login({
    required String email,
    required String password,
  });

  Future<Result<AppUser>> register({
    required String nombre,
    required String apellido,
    required String email,
    String? telefono,
    required String password,
  });

  Future<Result<void>> signOut();

  Future<Result<void>> softDeleteCurrentUser();

  Future<Result<AppUser?>> currentUser();
}
