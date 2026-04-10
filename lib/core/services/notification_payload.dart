/// Modelo que representa los datos de una notificación de baja afluencia.
class NotificationPayload {
  /// Identificador único del establecimiento relacionado con la notificación.
  final String establishmentId;

  /// Nombre del establecimiento para mostrar en la notificación.
  final String establishmentName;

  /// Nivel de afluencia actual (porcentaje 0–100).
  final int afluenciaLevel;

  const NotificationPayload({
    required this.establishmentId,
    required this.establishmentName,
    required this.afluenciaLevel,
  });

  /// Título de la notificación mostrado al usuario.
  String get title => '¡Baja afluencia en $establishmentName!';

  /// Cuerpo de la notificación mostrado al usuario.
  String get body =>
      'La afluencia actual es del $afluenciaLevel%. ¡Buen momento para visitar!';

  /// Serializa el payload a String para adjuntarlo a la notificación
  /// y recuperar el [establishmentId] al hacer tap (ENH-153).
  String toPayloadString() => establishmentId;

  /// Un ID numérico único por establecimiento para android, derivado del hash.
  int get notificationId => establishmentId.hashCode.abs();
}
