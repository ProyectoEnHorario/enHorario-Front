import 'package:enhorario/app/theme/app_theme.dart';
import 'package:enhorario/features/auth/presentation/pages/login_selection_page.dart';
import 'package:enhorario/features/auth/presentation/pages/real_app_placeholder_page.dart';
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
      home: Builder(
        builder: (context) => LoginSelectionPage(
          onEnterRealApp: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const RealAppPlaceholderPage(),
              ),
            );
          },
          onEnterTestMode: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AuthGateScreen()),
            );
          },
        ),
      ),
    );
  }
}
