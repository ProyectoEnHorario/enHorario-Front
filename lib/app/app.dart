import 'package:enhorario/app/theme/app_theme.dart';
import 'package:enhorario/features/auth/presentation/pages/admin_placeholder_page.dart';
import 'package:enhorario/features/auth/presentation/pages/login_selection_page.dart';
import 'package:enhorario/features/auth/presentation/pages/auth_gate_screen.dart';
import 'package:enhorario/features/establishments/presentation/pages/real_establishment_search_screen.dart';
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
                builder: (_) => const RealEstablishmentSearchScreen(),
              ),
            );
          },
          onEnterTestMode: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const AuthGateScreen()),
            );
          },
          onEnterAdmin: () {
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => const AdminPlaceholderPage(),
              ),
            );
          },
        ),
      ),
    );
  }
}
