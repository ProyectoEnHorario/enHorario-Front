import 'package:enhorario/core/enums/app_role.dart';

class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.rol,
    this.telefono,
    this.profilePhotoUrl,
    required this.createdAt,
    this.deletedAt,
  });

  final String uid;
  final String email;
  final String nombre;
  final String apellido;
  final AppRole rol;
  final String? telefono;
  final String? profilePhotoUrl;
  final DateTime createdAt;
  final DateTime? deletedAt;

  bool get estaActivo => deletedAt == null;
}
