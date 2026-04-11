import 'package:enhorario/app/app.dart';
import 'package:enhorario/features/notifications/data/repositories/local_notification_repository.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final notificationRepo = LocalNotificationRepository();
  final result = await notificationRepo.initialize();
  
  result.fold(
    (failure) {
      FlutterError.reportError(FlutterErrorDetails(
        exception: failure,
        library: 'Notificaciones',
        context: ErrorDescription('Falló la inicialización de notificaciones locales'),
      ));
    },
    (_) {},
  );

  runApp(EnHorarioApp(notificationRepository: notificationRepo));
}
