import 'package:enhorario/core/results/result.dart';

class RegisterAccountRequest {
  const RegisterAccountRequest({
    required this.nombre,
    required this.apellido,
    required this.email,
    required this.password,
  });

  final String nombre;
  final String apellido;
  final String email;
  final String password;
}

abstract class RegisterAccountService {
  Future<Result<void>> register(RegisterAccountRequest request);
}
