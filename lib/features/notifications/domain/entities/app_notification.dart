import 'package:equatable/equatable.dart';

class AppNotification extends Equatable {
  const AppNotification({
    required this.id,
    required this.title,
    required this.body,
    this.establishmentId,
    this.afluenciaLevel,
  });

  final int id;
  final String title;
  final String body;
  final String? establishmentId;
  final String? afluenciaLevel;

  /// Crea una notificación formateada para baja afluencia.
  factory AppNotification.lowAfluencia({
    required int id,
    required String establishmentName,
    required String establishmentId,
    required String afluenciaLevel,
  }) {
    return AppNotification(
      id: id,
      title: '¡Es el momento ideal! ⏱️',
      body: '$establishmentName tiene poca fila ($afluenciaLevel ahora mismo). ¡Aprovecha para ir!',
      establishmentId: establishmentId,
      afluenciaLevel: afluenciaLevel,
    );
  }

  String get payload => establishmentId ?? '';

  @override
  List<Object?> get props => [id, title, body, establishmentId, afluenciaLevel];
}
