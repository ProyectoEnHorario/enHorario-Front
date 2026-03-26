class RailwayEstablishmentView {
  const RailwayEstablishmentView({
    required this.id,
    required this.name,
    required this.addressLine,
    required this.city,
    required this.status,
    required this.averageWaitMinutes,
    required this.updatedAt,
    this.shortDescription,
    this.categoryName,
  });

  final String id;
  final String name;
  final String addressLine;
  final String city;
  final String status;
  final int? averageWaitMinutes;
  final DateTime? updatedAt;
  final String? shortDescription;
  final String? categoryName;

  bool get isOpen => status.toUpperCase() == 'OPEN';

  factory RailwayEstablishmentView.fromMap(Map<String, dynamic> map) {
    DateTime? parsedUpdatedAt;
    final rawUpdatedAt = map['updatedAt'];
    if (rawUpdatedAt is String && rawUpdatedAt.trim().isNotEmpty) {
      parsedUpdatedAt = DateTime.tryParse(rawUpdatedAt)?.toLocal();
    }

    final rawMinutes = map['averageWaitMinutes'];
    int? minutes;
    if (rawMinutes is int) {
      minutes = rawMinutes;
    } else if (rawMinutes is String) {
      minutes = int.tryParse(rawMinutes);
    }

    return RailwayEstablishmentView(
      id: map['id']?.toString() ?? '',
      name: map['name']?.toString() ?? 'Sin nombre',
      addressLine: map['addressLine']?.toString() ?? 'Sin direccion',
      city: map['city']?.toString() ?? 'Sin ciudad',
      status: map['status']?.toString() ?? 'CLOSED',
      averageWaitMinutes: minutes,
      updatedAt: parsedUpdatedAt,
      shortDescription: map['shortDescription']?.toString(),
      categoryName: map['categoryName']?.toString(),
    );
  }
}
