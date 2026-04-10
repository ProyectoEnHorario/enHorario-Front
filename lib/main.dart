import 'package:enhorario/app/app.dart';
import 'package:flutter/material.dart';
import 'package:enhorario/core/services/notification_service.dart';
import 'package:enhorario/core/services/afluencia_monitor_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  
  // Iniciar monitoreo de afluencia (ENH-149)
  AfluenciaMonitorService().startMonitoring();

  runApp(const EnHorarioApp());
}
