import 'package:enhorario/app/theme/app_theme.dart';
import 'package:enhorario/features/auth/presentation/pages/auth_gate_screen.dart';
import 'package:flutter/material.dart';

class EnHorarioApp extends StatelessWidget {
  const EnHorarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EnHorario',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: const AuthGateScreen(),
    );
  }
}
