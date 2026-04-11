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
        for (final est in establishments) {
          final notification = AppNotification.lowAfluencia(
            id: est.id.hashCode, // Generamos un ID único para la notificación
            establishmentName: est.name,
            establishmentId: est.id,
            afluenciaLevel: 'Baja',
          );

          await _notificationRepository.showAppNotification(notification);
        }
      },
    );

    emit(const NotificationTriggerState(isChecking: false));
  }
}
