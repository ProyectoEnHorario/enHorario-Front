import 'package:enhorario/core/utils/date_mapper.dart';

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
    String _asString(Object? v) => v == null ? '' : v.toString();

    String codigo = _asString(
      map['codigo'] ?? map['turnCode'] ?? map['turn_code'],
    );
    String tipo = _asString(
      map['tipo'] ?? map['turnType'] ?? map['turn_type'],
    ).toLowerCase();
    String estadoRaw = _asString(map['estado'] ?? map['status']);
    String estado;
    switch (estadoRaw.toUpperCase()) {
      case 'WAITING':
        estado = 'en_espera';
        break;
      case 'CALLED':
        estado = 'en_atencion';
        break;
      case 'ATTENDED':
        estado = 'atendido';
        break;
      case 'CANCELLED':
        estado = 'cancelado';
        break;
      default:
        estado = estadoRaw.isEmpty ? 'en_espera' : estadoRaw.toLowerCase();
    }

    int posicion = 0;
    final posVal =
        map['posicion'] ?? map['queuePosition'] ?? map['queue_position'];
    if (posVal is int)
      posicion = posVal;
    else if (posVal != null)
      posicion = int.tryParse(_asString(posVal)) ?? 0;

    return TurnModel(
      id: _asString(id.isNotEmpty ? id : map['id']),
      userId: _asString(map['userId'] ?? map['user_id']),
      establishmentId: _asString(
        map['establishmentId'] ?? map['establishment_id'],
      ),
      codigo: codigo,
      tipo: tipo.isEmpty ? 'regular' : tipo,
      estado: estado,
      posicion: posicion,
      solicitadoEn:
          DateMapper.toDateTime(
            map['solicitadoEn'] ?? map['requestedAt'] ?? map['requested_at'],
          ) ??
          DateTime.now(),
      atendidoEn: DateMapper.toDateTime(
        map['attendedAt'] ?? map['attended_at'] ?? map['atendidoEn'],
      ),
      canceladoEn: DateMapper.toDateTime(
        map['cancelledAt'] ?? map['cancelled_at'] ?? map['canceladoEn'],
      ),
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
      'solicitadoEn': DateMapper.toIsoString(solicitadoEn),
      'atendidoEn': DateMapper.toIsoString(atendidoEn),
      'canceladoEn': DateMapper.toIsoString(canceladoEn),
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
