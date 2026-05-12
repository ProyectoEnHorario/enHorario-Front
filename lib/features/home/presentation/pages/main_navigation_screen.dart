import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:enhorario/features/auth/data/repositories/railway_user_repository.dart';
import 'package:enhorario/features/auth/domain/repositories/user_repository.dart';
import 'package:enhorario/features/auth/presentation/bloc/user_profile_cubit.dart';
import 'package:enhorario/features/auth/presentation/pages/real_app_entry_screen.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_favorites_repository.dart';
import 'package:enhorario/features/establishments/domain/repositories/favorites_repository.dart';
import 'package:enhorario/features/establishments/presentation/bloc/favorites_cubit.dart';
import 'package:enhorario/features/establishments/presentation/bloc/real_establishments_cubit.dart';
import 'package:enhorario/features/establishments/presentation/pages/favorites_screen.dart';
import 'package:enhorario/features/establishments/presentation/pages/pantalla_inicio_app_real.dart';
import 'package:enhorario/features/home/presentation/pages/user_profile_screen.dart';
import 'package:enhorario/features/notifications/domain/entities/app_notification.dart';
import 'package:enhorario/features/notifications/domain/repositories/notification_repository.dart';
import 'package:enhorario/features/turns/presentation/pages/turns_screen.dart';
<<<<<<< HEAD
=======
import 'package:enhorario/features/admin/presentation/pages/user_management_screen.dart';
import 'package:enhorario/features/auth/data/repositories/railway_user_repository.dart';
import 'package:enhorario/features/auth/domain/repositories/user_repository.dart';
import 'package:enhorario/features/auth/presentation/bloc/user_profile_cubit.dart';
>>>>>>> 71f752e (feat(ENH-294): implementar pantalla de gestión de usuarios para superadmin y endpoints base)
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;

  List<String> _getNavigationTitles(bool isSuperAdmin) {
    return [
      'Establecimientos',
      'Favoritos',
      'Mi Información',
      'Tickets',
      if (isSuperAdmin) 'Administración',
    ];
  }

  List<Widget> _getPages(bool isSuperAdmin) {
    return [
      const PantallaInicioAppReal(),
      const FavoritesScreen(),
      const UserProfileScreen(),
      const TurnsScreen(),
      if (isSuperAdmin) const UserManagementScreen(),
    ];
  }

  List<NavigationDestination> _getDestinations(bool isSuperAdmin) {
    return [
      const NavigationDestination(
        icon: Icon(Icons.home_outlined),
        selectedIcon: Icon(Icons.home),
        label: 'Establecimientos',
      ),
      const NavigationDestination(
        icon: Icon(Icons.favorite_outline),
        selectedIcon: Icon(Icons.favorite),
        label: 'Favoritos',
      ),
      const NavigationDestination(
        icon: Icon(Icons.person_outline),
        selectedIcon: Icon(Icons.person),
        label: 'Mi Información',
      ),
      const NavigationDestination(
        icon: Icon(Icons.receipt_long_outlined),
        selectedIcon: Icon(Icons.receipt_long),
        label: 'Tickets',
      ),
      if (isSuperAdmin)
        const NavigationDestination(
          icon: Icon(Icons.admin_panel_settings_outlined),
          selectedIcon: Icon(Icons.admin_panel_settings),
          label: 'Admin',
        ),
    ];
  }

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
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<ApiClient>(
          create: (_) => ApiClient(),
        ),
        RepositoryProvider<UserRepository>(
          create: (context) => RailwayUserRepository(
            context.read<ApiClient>(),
          ),
        ),
        RepositoryProvider<FavoritesRepository>(
          create: (context) => RailwayFavoritesRepository(
            context.read<ApiClient>(),
          ),
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) => FavoritesCubit(
              context.read<FavoritesRepository>(),
            ),
          ),
          BlocProvider(
            create: (context) => RealEstablishmentsCubit(
              RailwayEstablishmentQueryService(context.read<ApiClient>()),
            ),
          ),
          BlocProvider(
            create: (context) => UserProfileCubit(
              context.read<UserRepository>(),
            )..loadProfile(),
          ),
        ],
        child: BlocBuilder<UserProfileCubit, UserProfileState>(
          builder: (context, userState) {
            final isSuperAdmin = userState.user?.rol == 'superadmin';
            final titles = _getNavigationTitles(isSuperAdmin);
            final pages = _getPages(isSuperAdmin);
            final destinations = _getDestinations(isSuperAdmin);

            // Ajuste de índice por si cambia el rol y se queda fuera de rango
            if (_selectedIndex >= destinations.length) {
              _selectedIndex = destinations.length - 1;
              if (_selectedIndex < 0) _selectedIndex = 0;
            }
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
                  title: Text(titles[_selectedIndex]),
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
                  children: pages,
                ),
                bottomNavigationBar: NavigationBar(
                  selectedIndex: _selectedIndex,
                  onDestinationSelected: (int index) {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  destinations: destinations,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
