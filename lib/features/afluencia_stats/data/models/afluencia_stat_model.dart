import 'package:enhorario/core/utils/date_mapper.dart';

class AfluenciaStatModel {
  const AfluenciaStatModel({
    required this.id,
    required this.establishmentId,
    required this.categoryId,
    required this.totalTurnos,
    required this.turnosPrioritarios,
    required this.fechaHora,
    required this.periodo,
  });

  final String id;
  final String establishmentId;
  final String categoryId;
  final int totalTurnos;
  final int turnosPrioritarios;
  final DateTime fechaHora;
  final String periodo;

  factory AfluenciaStatModel.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return AfluenciaStatModel(
      id: id,
      establishmentId: (map['establishmentId'] ?? '') as String,
      categoryId: (map['categoryId'] ?? '') as String,
      totalTurnos: (map['totalTurnos'] ?? 0) as int,
      turnosPrioritarios: (map['turnosPrioritarios'] ?? 0) as int,
      fechaHora: DateMapper.toDateTime(map['fechaHora']) ?? DateTime.now(),
      periodo: (map['periodo'] ?? 'diario') as String,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'establishmentId': establishmentId,
      'categoryId': categoryId,
      'totalTurnos': totalTurnos,
      'turnosPrioritarios': turnosPrioritarios,
      'fechaHora': DateMapper.toIsoString(fechaHora),
      'periodo': periodo,
    };
  }

  AfluenciaStatModel copyWith({
    String? id,
    String? establishmentId,
    String? categoryId,
    int? totalTurnos,
    int? turnosPrioritarios,
    DateTime? fechaHora,
    String? periodo,
  }) {
    return AfluenciaStatModel(
      id: id ?? this.id,
      establishmentId: establishmentId ?? this.establishmentId,
      categoryId: categoryId ?? this.categoryId,
      totalTurnos: totalTurnos ?? this.totalTurnos,
      turnosPrioritarios: turnosPrioritarios ?? this.turnosPrioritarios,
      fechaHora: fechaHora ?? this.fechaHora,
      periodo: periodo ?? this.periodo,
    );
  }
}
