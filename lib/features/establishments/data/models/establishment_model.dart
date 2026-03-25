import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enhorario/core/utils/firestore_mapper.dart';

class EstablishmentModel {
  const EstablishmentModel({
    required this.id,
    required this.nombre,
    required this.nombreNormalizado,
    this.descripcion,
    required this.direccion,
    required this.categoryId,
    required this.adminId,
    required this.activo,
    required this.abierto,
    required this.createdAt,
  });

  final String id;
  final String nombre;
  final String nombreNormalizado;
  final String? descripcion;
  final String direccion;
  final String categoryId;
  final String adminId;
  final bool activo;
  final bool abierto;
  final DateTime createdAt;

  factory EstablishmentModel.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return EstablishmentModel(
      id: id,
      nombre: (map['nombre'] ?? '') as String,
      nombreNormalizado: (map['nombreNormalizado'] ?? '') as String,
      descripcion: map['descripcion'] as String?,
      direccion: (map['direccion'] ?? '') as String,
      categoryId: (map['categoryId'] ?? '') as String,
      adminId: (map['adminId'] ?? '') as String,
      activo: (map['activo'] ?? true) as bool,
      abierto: (map['abierto'] ?? false) as bool,
      createdAt: FirestoreMapper.toDateTime(map['createdAt']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nombre': nombre,
      'nombreNormalizado': nombreNormalizado,
      'descripcion': descripcion,
      'direccion': direccion,
      'categoryId': categoryId,
      'adminId': adminId,
      'activo': activo,
      'abierto': abierto,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  EstablishmentModel copyWith({
    String? id,
    String? nombre,
    String? nombreNormalizado,
    String? descripcion,
    bool clearDescripcion = false,
    String? direccion,
    String? categoryId,
    String? adminId,
    bool? activo,
    bool? abierto,
    DateTime? createdAt,
  }) {
    return EstablishmentModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      nombreNormalizado: nombreNormalizado ?? this.nombreNormalizado,
      descripcion: clearDescripcion ? null : (descripcion ?? this.descripcion),
      direccion: direccion ?? this.direccion,
      categoryId: categoryId ?? this.categoryId,
      adminId: adminId ?? this.adminId,
      activo: activo ?? this.activo,
      abierto: abierto ?? this.abierto,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
