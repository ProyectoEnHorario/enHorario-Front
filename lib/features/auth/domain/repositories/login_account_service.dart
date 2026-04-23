import 'package:enhorario/core/results/result.dart';

class LoginAccountRequest {
  const LoginAccountRequest({required this.email, required this.password});

  final String email;
  final String password;
}

class LoginAccountSuccess {
  const LoginAccountSuccess({
    required this.token,
    required this.email,
    this.role,
    this.userId,
  });

  final String token;
  final String email;
  final String? role;
  final String? userId;
}

abstract class LoginAccountService {
  Future<Result<LoginAccountSuccess>> login(LoginAccountRequest request);
}
