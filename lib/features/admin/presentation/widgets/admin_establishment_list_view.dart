import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:enhorario/features/auth/presentation/bloc/user_management_cubit.dart';
import 'package:enhorario/features/establishments/presentation/bloc/real_establishments_cubit.dart';
import 'package:enhorario/core/enums/app_role.dart';

class AdminEstablishmentListView extends StatelessWidget {
  const AdminEstablishmentListView({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserManagementCubit, UserManagementState>(
      builder: (context, userState) {
        final admins = userState.users.where((u) => u.rol == AppRole.adminLocal || u.rol == AppRole.admin).toList();

        if (admins.isEmpty) {
          return const Center(child: Text('No hay administradores registrados.'));
        }

        return BlocBuilder<RealEstablishmentsCubit, RealEstablishmentsState>(
          builder: (context, estState) {
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: admins.length,
              itemBuilder: (context, index) {
                final admin = admins[index];
                // Filtramos los establecimientos del estado global que pertenecen a este admin
                // Nota: En una app real, esto podría requerir una consulta por adminId si no tenemos todo cargado
                final myEsts = estState.items.where((e) => true).toList(); // Placeholder: necesitamos el link real
                
                // Como no tenemos el campo owner en el modelo de establecimiento del front aún, 
                // simularemos que mostramos los que coinciden en alguna lógica o simplemente listamos el admin.
                
                return ExpansionTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text('${admin.nombre} ${admin.apellido}'),
                  subtitle: Text(admin.email),
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Establecimientos asignados:', style: TextStyle(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          // Aquí mostraríamos la lista de sus locales
                          const Text('• Local Principal (Simulado)'),
                          const SizedBox(height: 12),
                        ],
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
