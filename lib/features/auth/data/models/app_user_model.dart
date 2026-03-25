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
    required super.createdAt,
    super.deletedAt,
  });

  factory AppUserModel.fromMap(Map<String, dynamic> map) {
    return AppUserModel(
      uid: (map['uid'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      nombre: (map['nombre'] ?? '') as String,
      apellido: (map['apellido'] ?? '') as String,
      rol: (map['rol'] ?? 'usuario') as String,
      telefono: map['telefono'] as String?,
      createdAt: DateMapper.toDateTime(map['createdAt']) ?? DateTime.now(),
      deletedAt: DateMapper.toDateTime(map['deletedAt']),
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
    DateTime? createdAt,
    DateTime? deletedAt,
    bool clearDeletedAt = false,
  }) {
    return AppUserModel(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      rol: rol ?? this.rol,
      telefono: telefono ?? this.telefono,
      createdAt: createdAt ?? this.createdAt,
      deletedAt: clearDeletedAt ? null : (deletedAt ?? this.deletedAt),
    );
  }
}
