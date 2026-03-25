import 'package:enhorario/features/afluencia_stats/presentation/pages/afluencia_stats_screen.dart';
import 'package:enhorario/features/auth/data/repositories/local_auth_repository.dart';
import 'package:enhorario/features/categories/presentation/pages/categories_screen.dart';
import 'package:enhorario/features/establishments/presentation/pages/establishments_screen.dart';
import 'package:enhorario/features/turns/presentation/pages/turns_screen.dart';
import 'package:enhorario/features/wait_times/presentation/pages/wait_times_screen.dart';
import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  static final LocalAuthRepository _authRepository = LocalAuthRepository();

  @override
  Widget build(BuildContext context) {
    final email = LocalAuthRepository.currentUserSync?.email ?? 'sin correo';

    return Scaffold(
      appBar: AppBar(
        title: const Text('EnHorario - Inicio'),
        actions: [
          IconButton(
            onPressed: () async {
              await _authRepository.signOut();
            },
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesion',
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Usuario autenticado: $email'),
          const SizedBox(height: 16),
          _item(context, 'CRUD Categorias', const CategoriesScreen()),
          _item(context, 'CRUD Establecimientos', const EstablishmentsScreen()),
          _item(context, 'CRUD Turnos', const TurnsScreen()),
          _item(context, 'CRUD Tiempos de espera', const WaitTimesScreen()),
          _item(
            context,
            'CRUD Estadisticas de afluencia',
            const AfluenciaStatsScreen(),
          ),
        ],
      ),
    );
  }

  Widget _item(BuildContext context, String title, Widget screen) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ElevatedButton(
        onPressed: () {
          Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
        },
        child: Text(title),
      ),
    );
  }
}
