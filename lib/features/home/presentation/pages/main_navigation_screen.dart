import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:enhorario/features/auth/presentation/pages/real_app_entry_screen.dart';
import 'package:enhorario/features/establishments/presentation/pages/favorites_screen.dart';
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
    'Favoritos',
    'Mi Información',
    'Tickets',
  ];

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: _selectedIndex == 0,
      onPopInvokedWithResult: (bool didPop, dynamic result) {
        if (!didPop && _selectedIndex != 0) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_navigationTitles[_selectedIndex]),
          leading: _selectedIndex != 0
              ? IconButton(
                  icon: const Icon(Icons.arrow_back),
                  onPressed: () {
                    setState(() {
                      _selectedIndex = 0;
                    });
                  },
                )
              : null,
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
            FavoritesScreen(),
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
              icon: Icon(Icons.favorite_outline),
              selectedIcon: Icon(Icons.favorite),
              label: 'Favoritos',
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
