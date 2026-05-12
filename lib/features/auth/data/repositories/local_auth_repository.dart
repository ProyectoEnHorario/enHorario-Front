import 'dart:async';

import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/auth/data/models/app_user_model.dart';
import 'package:enhorario/features/auth/domain/entities/app_user.dart';
import 'package:enhorario/features/auth/domain/repositories/auth_repository.dart';

class LocalAuthRepository implements AuthRepository {
  LocalAuthRepository() {
    _seedIfNeeded();
  }

  static final StreamController<AppUser?> _authController =
      StreamController<AppUser?>.broadcast();

  static final Map<String, _StoredUser> _usersByEmail = {};
  static AppUserModel? _currentUser;
  static bool _seeded = false;

  static AppUserModel? get currentUserSync => _currentUser;

  @override
  Stream<AppUser?> authState() async* {
    yield _currentUser;
    yield* _authController.stream;
  }

  @override
  Future<Result<AppUser?>> currentUser() async {
    return Right<Failure, AppUser?>(_currentUser);
  }

  @override
  Future<Result<AppUser>> login({
    required String email,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    final stored = _usersByEmail[normalized];
    if (stored == null || stored.password != password) {
      return const Left<Failure, AppUser>(Failure('Credenciales invalidas'));
    }
    if (stored.user.deletedAt != null) {
      return const Left<Failure, AppUser>(
        Failure('La cuenta fue desactivada anteriormente'),
      );
    }

    _currentUser = stored.user;
    _authController.add(_currentUser);
    return Right<Failure, AppUser>(_currentUser!);
  }

  @override
  Future<Result<AppUser>> register({
    required String nombre,
    required String apellido,
    required String email,
    String? telefono,
    required String password,
  }) async {
    final normalized = email.trim().toLowerCase();
    if (_usersByEmail.containsKey(normalized)) {
      return const Left<Failure, AppUser>(Failure('El correo ya esta en uso'));
    }

    final user = AppUserModel(
      uid: _generateId('usr'),
      email: normalized,
      nombre: nombre.trim(),
      apellido: apellido.trim(),
      rol: 'USER',
      telefono: telefono?.trim().isEmpty == true ? null : telefono?.trim(),
      createdAt: DateTime.now(),
    );
    _usersByEmail[normalized] = _StoredUser(user: user, password: password);
    _currentUser = user;
    _authController.add(_currentUser);
    return Right<Failure, AppUser>(user);
  }

  @override
  Future<Result<void>> signOut() async {
    _currentUser = null;
    _authController.add(null);
    return const Right<Failure, void>(null);
  }

  @override
  Future<Result<void>> softDeleteCurrentUser() async {
    if (_currentUser == null) {
      return const Left<Failure, void>(Failure('No hay sesion activa'));
    }

    final deleted = _currentUser!.copyWith(deletedAt: DateTime.now());
    _usersByEmail[deleted.email] = _StoredUser(
      user: deleted,
      password: _usersByEmail[deleted.email]?.password ?? '',
    );
    _currentUser = null;
    _authController.add(null);
    return const Right<Failure, void>(null);
  }

  void _seedIfNeeded() {
    if (_seeded) return;

    final admin = AppUserModel(
      uid: 'usr-admin',
      email: 'admin@enhorario.com',
      nombre: 'Admin',
      apellido: 'Test',
      rol: 'SUPERADMIN',
      telefono: '3000000000',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
    );
    final tester = AppUserModel(
      uid: 'usr-tester',
      email: 'test@enhorario.com',
      nombre: 'Usuario',
      apellido: 'Pruebas',
      rol: 'USER',
      telefono: '3001111111',
      createdAt: DateTime.now().subtract(const Duration(days: 15)),
    );

    _usersByEmail[admin.email] = _StoredUser(
      user: admin,
      password: 'admin123',
    );
    _usersByEmail[tester.email] = _StoredUser(
      user: tester,
      password: 'test1234',
    );
    _seeded = true;
  }

  static String _generateId(String prefix) {
    return '$prefix-${DateTime.now().microsecondsSinceEpoch}';
  }
}

class _StoredUser {
  const _StoredUser({required this.user, required this.password});

  final AppUserModel user;
  final String password;
}
