import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/core/errors/failure.dart';

abstract class NotificationRepository {
  /// Inicializa el servicio de notificaciones.
  Future<Result<void>> initialize();

  /// Muestra una notificación inmediata.
  Future<Result<void>> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  });

  /// Solicita permisos al sistema.
  Future<bool> requestPermissions();

  /// Verifica si las notificaciones están habilitadas a nivel sistema.
  Future<bool> isEnabled();

  /// Cancela todas las notificaciones pendientes.
  Future<void> cancelAll();
}
