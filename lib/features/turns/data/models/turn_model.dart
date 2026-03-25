import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enhorario/core/utils/firestore_mapper.dart';

class TurnModel {
  const TurnModel({
    required this.id,
    required this.userId,
    required this.establishmentId,
    required this.codigo,
    required this.tipo,
    required this.estado,
    required this.posicion,
    required this.solicitadoEn,
    this.atendidoEn,
    this.canceladoEn,
  });

  final String id;
  final String userId;
  final String establishmentId;
  final String codigo;
  final String tipo;
  final String estado;
  final int posicion;
  final DateTime solicitadoEn;
  final DateTime? atendidoEn;
  final DateTime? canceladoEn;

  factory TurnModel.fromMap(Map<String, dynamic> map, {required String id}) {
    return TurnModel(
      id: id,
      userId: (map['userId'] ?? '') as String,
      establishmentId: (map['establishmentId'] ?? '') as String,
      codigo: (map['codigo'] ?? '') as String,
      tipo: (map['tipo'] ?? 'regular') as String,
      estado: (map['estado'] ?? 'en_espera') as String,
      posicion: (map['posicion'] ?? 0) as int,
      solicitadoEn:
          FirestoreMapper.toDateTime(map['solicitadoEn']) ?? DateTime.now(),
      atendidoEn: FirestoreMapper.toDateTime(map['atendidoEn']),
      canceladoEn: FirestoreMapper.toDateTime(map['canceladoEn']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'establishmentId': establishmentId,
      'codigo': codigo,
      'tipo': tipo,
      'estado': estado,
      'posicion': posicion,
      'solicitadoEn': Timestamp.fromDate(solicitadoEn),
      'atendidoEn': FirestoreMapper.toTimestamp(atendidoEn),
      'canceladoEn': FirestoreMapper.toTimestamp(canceladoEn),
    };
  }

  TurnModel copyWith({
    String? id,
    String? userId,
    String? establishmentId,
    String? codigo,
    String? tipo,
    String? estado,
    int? posicion,
    DateTime? solicitadoEn,
    DateTime? atendidoEn,
    bool clearAtendidoEn = false,
    DateTime? canceladoEn,
    bool clearCanceladoEn = false,
  }) {
    return TurnModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      establishmentId: establishmentId ?? this.establishmentId,
      codigo: codigo ?? this.codigo,
      tipo: tipo ?? this.tipo,
      estado: estado ?? this.estado,
      posicion: posicion ?? this.posicion,
      solicitadoEn: solicitadoEn ?? this.solicitadoEn,
      atendidoEn: clearAtendidoEn ? null : (atendidoEn ?? this.atendidoEn),
      canceladoEn: clearCanceladoEn ? null : (canceladoEn ?? this.canceladoEn),
    );
  }
}
