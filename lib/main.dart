import 'package:enhorario/app/app.dart';
import 'package:enhorario/features/notifications/data/repositories/local_notification_repository.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final notificationRepo = LocalNotificationRepository();
  final result = await notificationRepo.initialize();
  
  result.fold(
    (failure) {
      debugPrint('[Main] Error crítico inicializando notificaciones: ${failure.message}');
      FlutterError.reportError(FlutterErrorDetails(
        exception: failure,
        library: 'Notificaciones',
        context: ErrorDescription('Falló la inicialización de notificaciones locales: ${failure.message}'),
      ));
      // La app continua pero el repositorio de notificaciones estara en un estado fallido interno
    },
    (_) => debugPrint('[Main] Notificaciones locales inicializadas correctamente'),
  );

  runApp(EnHorarioApp(notificationRepository: notificationRepo));
}
