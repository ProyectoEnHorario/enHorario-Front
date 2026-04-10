import 'package:enhorario/app/app.dart';
import 'package:flutter/material.dart';
import 'package:enhorario/core/services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();
  runApp(const EnHorarioApp());
}
