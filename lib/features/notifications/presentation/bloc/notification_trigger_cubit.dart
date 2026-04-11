import 'package:enhorario/features/notifications/data/services/low_afluencia_service.dart';
import 'package:enhorario/features/notifications/domain/entities/app_notification.dart';
import 'package:enhorario/features/notifications/domain/repositories/notification_repository.dart';
import 'package:enhorario/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationTriggerState {
  const NotificationTriggerState({this.isChecking = false});
  final bool isChecking;
}

class NotificationTriggerCubit extends Cubit<NotificationTriggerState> {
  NotificationTriggerCubit({
    required LowAfluenciaService lowAfluenciaService,
    required NotificationRepository notificationRepository,
    required NotificationsCubit notificationsCubit,
  })  : _lowAfluenciaService = lowAfluenciaService,
        _notificationRepository = notificationRepository,
        _notificationsCubit = notificationsCubit,
        super(const NotificationTriggerState());

  final LowAfluenciaService _lowAfluenciaService;
  final NotificationRepository _notificationRepository;
  final NotificationsCubit _notificationsCubit;

  // Mapa para rastrear cuándo se envió la última notificación por establecimiento
  final Map<String, DateTime> _lastSentNotifications = {};

  // Tiempo mínimo entre notificaciones para el mismo establecimiento (1 hora)
  static const Duration _cooldownDuration = Duration(hours: 1);

  int _generateNotificationId(String id) {
    int hash = 0x811c9dc5;
    for (int i = 0; i < id.length; i++) {
      hash ^= id.codeUnitAt(i);
      hash = (hash * 0x01000193) & 0xFFFFFFFF;
    }
    return hash.abs() & 0x7FFFFFFF;
  }

  Future<void> checkAndNotify() async {
    // Verificar si las notificaciones están habilitadas por el usuario
    if (!_notificationsCubit.state.isNotificationsEnabled) {
      debugPrint('[Trigger] Notificaciones desactivadas por el usuario. Saltando chequeo.');
      return;
    }

    // Verificar también el permiso real del sistema antes de intentar notificar
    final systemNotificationsEnabled = await _notificationRepository.isEnabled();
    if (!systemNotificationsEnabled) {
      debugPrint('[Trigger] Permiso de notificaciones no concedido por el sistema. Saltando chequeo.');
      return;
    }
    if (state.isChecking) return;

    emit(const NotificationTriggerState(isChecking: true));

    try {
      final result = await _lowAfluenciaService.getLowAfluenciaAlerts();

      await result.fold(
        (failure) async {
          debugPrint('[Trigger Error] Fallo al consultar afluencia: ${failure.message}');
          if (failure.message.contains('404')) {
            debugPrint('[Trigger Error] Sugerencia: El establecimiento podría haber sido eliminado.');
          } else if (failure.message.contains('500')) {
            debugPrint('[Trigger Error] Sugerencia: Error interno del servidor Railway.');
          }
        },
        (establishments) async {
          if (establishments.isEmpty) {
            debugPrint('[Trigger] No se detectaron establecimientos con baja afluencia actualmente.');
            return;
          }

          final now = DateTime.now();

          for (final est in establishments) {
            // Verificar cooldown
            final lastSent = _lastSentNotifications[est.id];
            if (lastSent != null && now.difference(lastSent) < _cooldownDuration) {
              debugPrint('Omitiendo notificación para ${est.name} (en periodo de cooldown)');
              continue;
            }

            final notification = AppNotification.lowAfluencia(
              id: _generateNotificationId(est.id),
              establishmentName: est.name,
              establishmentId: est.id,
              afluenciaLevel: 'Baja',
            );

            final result = await _notificationRepository.showAppNotification(notification);
            
            // Registrar envío solo si tuvo éxito
            result.fold(
              (failure) => debugPrint('Error al mostrar notificación: ${failure.message}'),
              (_) => _lastSentNotifications[est.id] = now,
            );
          }
        },
      );
    } catch (e) {
      debugPrint('[Trigger Error] Error inesperado en el chequeo: $e');
    } finally {
      emit(const NotificationTriggerState(isChecking: false));
    }
  }
}
