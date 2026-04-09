import 'package:enhorario/features/afluencia_stats/presentation/pages/afluencia_stats_screen.dart';
import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:enhorario/features/auth/presentation/pages/real_app_entry_screen.dart';
import 'package:enhorario/features/categories/presentation/pages/categories_screen.dart';
import 'package:enhorario/features/establishments/presentation/pages/pantalla_establecimientos.dart';
import 'package:flutter/material.dart';

class AdminPlaceholderPage extends StatefulWidget {
  const AdminPlaceholderPage({super.key});

  @override
  State<AdminPlaceholderPage> createState() => _AdminPlaceholderPageState();
}

class _AdminPlaceholderPageState extends State<AdminPlaceholderPage> {
  int _selectedIndex = 0;

  Future<bool> _canAccessAdminPanel() async {
    final sessionRepository = AuthSessionRepository();
    final hasSession = await sessionRepository.hasSession();
    if (!hasSession) return false;

    final role = (await sessionRepository.getCurrentUserRole())
        ?.trim()
        .toLowerCase();

    // Si el rol no viene en el login, permitimos abrir el panel y dejamos
    // que el backend valide acceso en cada endpoint de estadisticas.
    if (role == null || role.isEmpty) {
      return true;
    }

    if (role == 'admin' || role == 'administrador') {
      return true;
    }

    return false;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _canAccessAdminPanel(),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final canAccess = snapshot.data ?? false;
        if (!canAccess) {
          return Scaffold(
            appBar: AppBar(title: const Text('Administrador')),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.lock_outline, size: 56),
                    const SizedBox(height: 12),
                    const Text(
                      'Acceso denegado. Solo usuarios con rol de administrador pueden ingresar al panel.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const RealAppEntryScreen(),
                          ),
                        ).then((_) {
                          if (!mounted) return;
                          setState(() {});
                        });
                      },
                      child: const Text('Iniciar sesion como administrador'),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () async {
                        await AuthSessionRepository().saveSession(
                          token: 'demo-admin-token',
                          email: 'admin@enhorario.com',
                          role: 'admin',
                        );
                        if (!mounted) return;
                        setState(() {});
                      },
                      child: const Text('Entrar con acceso admin de prueba'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(
              _selectedIndex == 0
                  ? 'Dashboard de estadisticas'
                  : 'Gestion de entidades',
            ),
          ),
          body: IndexedStack(
            index: _selectedIndex,
            children: const [
              AfluenciaStatsScreen(),
              _AdminEntitiesHub(),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            destinations: const [
              NavigationDestination(
                icon: Icon(Icons.dashboard_outlined),
                selectedIcon: Icon(Icons.dashboard),
                label: 'Dashboard',
              ),
              NavigationDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: 'Gestion',
              ),
            ],
          ),
        );
      },
    );
  }
}

class _AdminEntitiesHub extends StatelessWidget {
  const _AdminEntitiesHub();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Card(
          child: ListTile(
            leading: const Icon(Icons.store_mall_directory_outlined),
            title: const Text('Administrar establecimientos'),
            subtitle: const Text('Crear, editar y eliminar establecimientos.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const PantallaEstablecimientos(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Card(
          child: ListTile(
            leading: const Icon(Icons.category_outlined),
            title: const Text('Administrar categorias'),
            subtitle: const Text('Crear, editar y eliminar categorias.'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => const CategoriesScreen(),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 20),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Este modulo centraliza la administracion de entidades para no afectar otras funcionalidades del sistema.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ),
      ],
    );
  }
}
