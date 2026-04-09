import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:enhorario/features/auth/presentation/pages/real_app_entry_screen.dart';
import 'package:enhorario/features/establishments/presentation/pages/pantalla_inicio_app_real.dart';
import 'package:enhorario/features/home/presentation/pages/user_profile_screen.dart';
import 'package:enhorario/features/turns/presentation/pages/turns_screen.dart';
import 'package:flutter/material.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  static const List<String> _navigationTitles = [
    'Establecimientos',
    'Mi Información',
    'Tickets',
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevenir volver atrás accidentalmente
      child: Scaffold(
        appBar: AppBar(
          title: Text(_navigationTitles[_selectedIndex]),
          actions: [
            IconButton(
              onPressed: () async {
                await AuthSessionRepository().clearSession();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const RealAppEntryScreen(),
                  ),
                  (_) => false,
                );
              },
              icon: const Icon(Icons.logout),
              tooltip: 'Cerrar sesión',
            ),
          ],
        ),
        body: IndexedStack(
          index: _selectedIndex,
          children: const [
            PantallaInicioAppReal(),
            UserProfileScreen(),
            TurnsScreen(),
          ],
        ),
        bottomNavigationBar: NavigationBar(
          selectedIndex: _selectedIndex,
          onDestinationSelected: (int index) {
            setState(() {
              _selectedIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home),
              label: 'Establecimientos',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person),
              label: 'Mi Información',
            ),
            NavigationDestination(
              icon: Icon(Icons.receipt_long_outlined),
              selectedIcon: Icon(Icons.receipt_long),
              label: 'Tickets',
            ),
          ],
        ),
      ),
    );
  }
}
