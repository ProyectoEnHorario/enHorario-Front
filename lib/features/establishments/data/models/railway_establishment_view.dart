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
    required this.latitude,
    required this.longitude,
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
  final double? latitude;
  final double? longitude;

  bool get isOpen => status.trim().toUpperCase() == 'OPEN';

  bool get hasValidCoordinates {
    if (latitude == null || longitude == null) return false;
    return latitude! >= -90 &&
        latitude! <= 90 &&
        longitude! >= -180 &&
        longitude! <= 180;
  }

  int get occupancyLevel {
    if (!isOpen) return 0;
    final wait = averageWaitMinutes;
    if (wait == null) return 1;
    if (wait <= 5) return 1;
    if (wait <= 15) return 2;
    return 3;
  }

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
      latitude: _toDouble(map['latitude']),
      longitude: _toDouble(map['longitude']),
    );
  }

  static int? _toInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value.toString());
  }

  static double? _toDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is num) return value.toDouble();
    return double.tryParse(value.toString());
  }
}
