class AppUser {
  const AppUser({
    required this.uid,
    required this.email,
    required this.nombre,
    required this.apellido,
    required this.rol,
    this.telefono,
    required this.createdAt,
    this.deletedAt,
  });

  final String uid;
  final String email;
  final String nombre;
  final String apellido;
  final String rol;
  final String? telefono;
  final DateTime createdAt;
  final DateTime? deletedAt;

  bool get estaActivo => deletedAt == null;
}
