import 'package:enhorario/core/utils/date_mapper.dart';

class RailwayEstablishmentView {
  const RailwayEstablishmentView({
    required this.id,
    required this.name,
    required this.addressLine,
    required this.city,
    required this.status,
    required this.averageWaitMinutes,
    required this.categoryName,
    required this.shortDescription,
    required this.updatedAt,
  });

  final String id;
  final String name;
  final String addressLine;
  final String city;
  final String status;
  final int? averageWaitMinutes;
  final String? categoryName;
  final String? shortDescription;
  final DateTime? updatedAt;

  bool get isOpen => status.trim().toUpperCase() == 'OPEN';

  factory RailwayEstablishmentView.fromMap(Map<String, dynamic> map) {
    return RailwayEstablishmentView(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Sin nombre',
      addressLine: map['addressLine']?.toString() ?? 'Sin direccion',
      city: map['city']?.toString() ?? 'Sin ciudad',
      status: map['status']?.toString() ?? 'CLOSED',
      averageWaitMinutes: _toInt(map['averageWaitMinutes']),
      categoryName: map['categoryName']?.toString(),
      shortDescription: map['shortDescription']?.toString(),
      updatedAt: DateMapper.toDateTime(map['updatedAt']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value.toString());
  }
}
