import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/auth/domain/entities/app_user.dart';

abstract class UserRepository {
  Future<Result<AppUser>> getUserProfile();
}
