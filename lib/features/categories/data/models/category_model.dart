class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.nombre,
    required this.icono,
    required this.activa,
  });

  final String id;
  final String nombre;
  final String icono;
  final bool activa;

  factory CategoryModel.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return CategoryModel(
      id: id,
      nombre: (map['nombre'] ?? '') as String,
      icono: (map['icono'] ?? 'category') as String,
      activa: (map['activa'] ?? true) as bool,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'nombre': nombre, 'icono': icono, 'activa': activa};
  }

  CategoryModel copyWith({
    String? id,
    String? nombre,
    String? icono,
    bool? activa,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      icono: icono ?? this.icono,
      activa: activa ?? this.activa,
    );
  }
}
