import 'package:enhorario/features/auth/presentation/pages/login_screen.dart';
import 'package:enhorario/features/auth/data/repositories/local_auth_repository.dart';
import 'package:enhorario/features/home/presentation/pages/home_screen.dart';
import 'package:flutter/material.dart';

class AuthGateScreen extends StatelessWidget {
  const AuthGateScreen({super.key});

  static final LocalAuthRepository _authRepository = LocalAuthRepository();

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: _authRepository.authState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          return const HomeScreen();
        }
        return const LoginScreen();
      },
    );
  }
}
