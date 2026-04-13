import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:enhorario/features/auth/presentation/pages/real_app_entry_screen.dart';
import 'package:enhorario/features/establishments/presentation/pages/favorites_screen.dart';
import 'package:enhorario/features/establishments/presentation/pages/pantalla_inicio_app_real.dart';
import 'package:enhorario/features/home/presentation/pages/user_profile_screen.dart';
import 'package:enhorario/features/notifications/domain/entities/app_notification.dart';
import 'package:enhorario/features/notifications/domain/repositories/notification_repository.dart';
import 'package:enhorario/features/turns/presentation/pages/turns_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

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

  /// Envía una notificación de prueba para verificar que el sistema funciona
  Future<void> _sendTestNotification(BuildContext context) async {
    final notificationRepo = context.read<NotificationRepository>();
    
    // 1. Verificar/Pedir permisos primero
    final hasPermission = await notificationRepo.requestPermissions();
    if (!hasPermission) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debes dar permisos de notificación primero')),
      );
      return;
    }

    // 2. Crear una notificación de prueba
    final testNotification = AppNotification.lowAfluencia(
      id: 999,
      establishmentName: 'Establecimiento de Prueba',
      establishmentId: 'test-id',
      afluenciaLevel: 'Baja',
    );

    // 3. Mostrarla
    final result = await notificationRepo.showAppNotification(testNotification);
    
    result.fold(
      (failure) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error al notificar: ${failure.message}')),
        );
      },
      (_) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Notificación de prueba enviada! Revisa tu barra superior.')),
        );
      },
    );
  }

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
            // Botón de PRUEBA de Notificación
            IconButton(
              onPressed: () => _sendTestNotification(context),
              icon: const Icon(Icons.notification_add),
              tooltip: 'Prueba de notificación',
              color: Colors.blue,
            ),
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
