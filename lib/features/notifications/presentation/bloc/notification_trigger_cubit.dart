import 'package:enhorario/features/notifications/data/services/low_afluencia_service.dart';
import 'package:enhorario/features/notifications/domain/entities/app_notification.dart';
import 'package:enhorario/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationTriggerState {
  const NotificationTriggerState({this.isChecking = false});
  final bool isChecking;
}

class NotificationTriggerCubit extends Cubit<NotificationTriggerState> {
  NotificationTriggerCubit({
    required LowAfluenciaService lowAfluenciaService,
    required NotificationRepository notificationRepository,
  })  : _lowAfluenciaService = lowAfluenciaService,
        _notificationRepository = notificationRepository,
        super(const NotificationTriggerState());

  final LowAfluenciaService _lowAfluenciaService;
  final NotificationRepository _notificationRepository;

  // Mapa para rastrear cuándo se envió la última notificación por establecimiento
  final Map<String, DateTime> _lastSentNotifications = {};

  // Tiempo mínimo entre notificaciones para el mismo establecimiento (1 hora)
  static const Duration _cooldownDuration = Duration(hours: 1);

  Future<void> checkAndNotify() async {
    if (state.isChecking) return;

    emit(const NotificationTriggerState(isChecking: true));

    final result = await _lowAfluenciaService.getLowAfluenciaAlerts();

    result.fold(
      (failure) {
        // En una app real podríamos loguear esto.
        print('Error chequeando afluencia: ${failure.message}');
      },
      (establishments) async {
        final now = DateTime.now();

        for (final est in establishments) {
          // Verificar cooldown
          final lastSent = _lastSentNotifications[est.id];
          if (lastSent != null && now.difference(lastSent) < _cooldownDuration) {
            print('Omitiendo notificación para ${est.name} (en periodo de cooldown)');
            continue;
          }

          final notification = AppNotification.lowAfluencia(
            id: est.id.hashCode,
            establishmentName: est.name,
            establishmentId: est.id,
            afluenciaLevel: 'Baja',
          );

          await _notificationRepository.showAppNotification(notification);
          
          // Registrar envío
          _lastSentNotifications[est.id] = now;
        }
      },
    );

    emit(const NotificationTriggerState(isChecking: false));
  }
}
