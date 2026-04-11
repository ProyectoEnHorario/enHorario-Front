import 'package:enhorario/app/app.dart';
import 'package:enhorario/features/notifications/data/repositories/local_notification_repository.dart';
import 'package:flutter/material.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  final notificationRepo = LocalNotificationRepository();
  await notificationRepo.initialize();
  
  runApp(EnHorarioApp(notificationRepository: notificationRepo));
}
