import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/notifications/domain/entities/app_notification.dart';
import 'package:enhorario/features/notifications/domain/entities/notification_status.dart';

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

  /// Muestra una notificación estructurada de la App.
  Future<Result<void>> showAppNotification(AppNotification notification);

  /// Solicita permisos al sistema.
  Future<bool> requestPermissions();

  /// Obtiene el estado detallado de los permisos.
  Future<NotificationStatus> getStatus();

  /// Solicita permisos y devuelve el estado detallado.
  Future<NotificationStatus> requestStatus();

  /// Verifica si las notificaciones están habilitadas a nivel sistema.
  Future<bool> isEnabled();

  /// Cancela todas las notificaciones pendientes.
  Future<void> cancelAll();
}
