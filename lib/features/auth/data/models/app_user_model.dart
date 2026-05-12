import 'package:enhorario/core/utils/date_mapper.dart';
import 'package:enhorario/features/auth/domain/entities/app_user.dart';

class AppUserModel extends AppUser {
  const AppUserModel({
    required super.uid,
    required super.email,
    required super.nombre,
    required super.apellido,
    required super.rol,
    super.telefono,
    super.profilePhotoUrl,
    required super.createdAt,
    super.deletedAt,
  });

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    // Soporta llaves del backend en inglés ('id', 'name', 'lastName', 'role', 'phone')
    // y mantiene fallback para llaves locales ('uid', 'nombre', 'apellido', 'rol', 'telefono')
    return AppUserModel(
      uid: (map['id'] ?? map['uid'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      nombre: (map['name'] ?? map['nombre'] ?? '') as String,
      apellido: (map['lastName'] ?? map['apellido'] ?? '') as String,
      rol: (map['role'] ?? map['rol'] ?? 'USER') as String,
      telefono: (map['phone'] ?? map['telefono']) as String?,
      profilePhotoUrl: map['profilePhotoUrl'] as String?,
      createdAt: DateMapper.toDateTime(map['createdAt']) ?? DateTime.now(),
      deletedAt: (map['isActive'] == false) ? DateTime.now() : DateMapper.toDateTime(map['deletedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'nombre': nombre,
      'apellido': apellido,
      'rol': rol,
      'telefono': telefono,
      'profilePhotoUrl': profilePhotoUrl,
      'createdAt': DateMapper.toIsoString(createdAt),
      'deletedAt': DateMapper.toIsoString(deletedAt),
    };
  }

  AppUserModel copyWith({
    String? uid,
    String? email,
    String? nombre,
    String? apellido,
    String? rol,
    String? telefono,
    String? profilePhotoUrl,
    DateTime? createdAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
    bool clearProfilePhotoUrl = false,
  }) {
    return AppUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      rol: rol ?? this.rol,
      telefono: telefono ?? this.telefono,
      profilePhotoUrl: clearProfilePhotoUrl ? null : (profilePhotoUrl ?? this.profilePhotoUrl),
      createdAt: createdAt ?? this.createdAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
