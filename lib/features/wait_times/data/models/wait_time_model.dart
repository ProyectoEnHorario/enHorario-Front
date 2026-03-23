import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:enhorario/core/utils/firestore_mapper.dart';

class WaitTimeModel {
  const WaitTimeModel({
    required this.id,
    required this.establishmentId,
    required this.minutos,
    required this.actualizadoEn,
  });

  final String id;
  final String establishmentId;
  final int minutos;
  final DateTime actualizadoEn;

  factory WaitTimeModel.fromMap(
    Map<String, dynamic> map, {
    required String id,
  }) {
    return WaitTimeModel(
      id: id,
      establishmentId: (map['establishmentId'] ?? '') as String,
      minutos: (map['minutos'] ?? 0) as int,
      actualizadoEn:
          FirestoreMapper.toDateTime(map['actualizadoEn']) ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'establishmentId': establishmentId,
      'minutos': minutos,
      'actualizadoEn': Timestamp.fromDate(actualizadoEn),
    };
  }

  WaitTimeModel copyWith({
    String? id,
    String? establishmentId,
    int? minutos,
    DateTime? actualizadoEn,
  }) {
    return WaitTimeModel(
      id: id ?? this.id,
      establishmentId: establishmentId ?? this.establishmentId,
      minutos: minutos ?? this.minutos,
      actualizadoEn: actualizadoEn ?? this.actualizadoEn,
    );
  }
}
