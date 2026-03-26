import 'dart:async';

import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/auth/domain/repositories/register_account_service.dart';

class MockRegisterAccountService implements RegisterAccountService {
  static final Set<String> _registeredEmails = <String>{
    'admin@enhorario.com',
    'test@enhorario.com',
  };

  @override
  Future<Result<void>> register(RegisterAccountRequest request) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));

    final normalizedEmail = request.email.trim().toLowerCase();

    if (_registeredEmails.contains(normalizedEmail)) {
      return const Left<Failure, void>(
        Failure('El correo ya esta registrado.'),
      );
    }

    if (normalizedEmail.contains('error-servidor')) {
      return const Left<Failure, void>(
        Failure('No pudimos completar el registro. Intenta de nuevo.'),
      );
    }

    _registeredEmails.add(normalizedEmail);
    return const Right<Failure, void>(null);
  }
}
