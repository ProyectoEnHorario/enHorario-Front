import 'package:enhorario/app/theme/app_theme.dart';
import 'package:enhorario/features/home/presentation/pages/home_screen.dart';
import 'package:flutter/material.dart';

class EnHorarioApp extends StatelessWidget {
  const EnHorarioApp({super.key});

  /// Llave global para acceder al Navigator desde servicios (ej. notificaciones)
  static final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      title: 'EnHorario',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const HomeScreen(),
    );
  }
}
