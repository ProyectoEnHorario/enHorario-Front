import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:enhorario/features/auth/presentation/pages/login_user_screen.dart';
import 'package:enhorario/features/auth/presentation/pages/real_app_placeholder_page.dart';
import 'package:flutter/material.dart';

class RealAppEntryScreen extends StatelessWidget {
  const RealAppEntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: AuthSessionRepository().hasSession(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasSession = snapshot.data ?? false;
        if (hasSession) {
          return const RealAppPlaceholderPage();
        }
        return const LoginUserScreen();
      },
    );
  }
}
