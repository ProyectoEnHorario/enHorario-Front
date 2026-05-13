import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/auth/data/repositories/railway_user_repository.dart';
import 'package:enhorario/features/auth/presentation/bloc/user_management_cubit.dart';
import 'package:enhorario/features/auth/presentation/bloc/user_profile_cubit.dart';
import 'package:enhorario/features/auth/domain/entities/app_user.dart';
import 'package:enhorario/core/navigation/role_guard.dart';
import 'package:enhorario/core/enums/app_role.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserManagementScreen extends StatelessWidget {
  const UserManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => UserManagementCubit(
        RailwayUserRepository(context.read<ApiClient>()),
      )..loadUsers(),
      child: const UserManagementView(),
    );
  }
}

class UserManagementView extends StatelessWidget {
  const UserManagementView({super.key});

  void _showRoleDialog(BuildContext context, AppUser user) {
    final cubit = context.read<UserManagementCubit>();
    AppRole selectedRole = user.rol;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Cambiar Rol'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Selecciona el nuevo rol para ${user.nombre} ${user.apellido}'),
                  const SizedBox(height: 16),
                  DropdownButton<AppRole>(
                    value: selectedRole,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: AppRole.user, child: Text('Usuario Normal')),
                      DropdownMenuItem(value: AppRole.superadmin, child: Text('Superadministrador')),
                    ],
                    onChanged: (val) {
                      if (val != null) {
                        setState(() => selectedRole = val);
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text('Cancelar'),
                ),
                FilledButton(
                  onPressed: () {
                    if (selectedRole == user.rol) {
                      Navigator.of(ctx).pop();
                      return; // No hay cambios
                    }

                    showDialog(
                      context: ctx,
                      builder: (confirmCtx) {
                        return AlertDialog(
                          title: const Text('Confirmar Cambio'),
                          content: Text(
                            '¿Estás seguro de que deseas cambiar el rol de ${user.nombre} a ${selectedRole.displayName.toUpperCase()}?\n\n'
                            'Esto alterará sus permisos dentro del sistema.',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(confirmCtx).pop(),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(backgroundColor: Colors.orange),
                              onPressed: () {
                                cubit.updateUserRole(user.uid, selectedRole.toBackendString());
                                Navigator.of(confirmCtx).pop(); // Cierra confirmación
                                Navigator.of(ctx).pop(); // Cierra diálogo original
                              },
                              child: const Text('Confirmar'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: const Text('Guardar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showDeleteDialog(BuildContext context, AppUser user) {
    final cubit = context.read<UserManagementCubit>();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Eliminar Usuario'),
          content: Text('¿Estás seguro de que deseas eliminar permanentemente a ${user.nombre}? Esta acción no se puede deshacer.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                cubit.deleteUser(user.uid);
                Navigator.of(ctx).pop();
              },
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserManagementCubit, UserManagementState>(
      listener: (context, state) {
        if (state.status == UserManagementStatus.error && state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
          context.read<UserManagementCubit>().clearError();
        } else if (state.status == UserManagementStatus.success && state.message != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message!), backgroundColor: Colors.green),
          );
          context.read<UserManagementCubit>().clearMessage();
        }
      },
      builder: (context, state) {
        final searchBar = Padding(
          padding: const EdgeInsets.all(16.0),
          child: TextField(
            decoration: InputDecoration(
              hintText: 'Buscar por nombre o correo...',
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onSubmitted: (value) {
              context.read<UserManagementCubit>().loadUsers(value);
            },
            textInputAction: TextInputAction.search,
          ),
        );

        Widget content;

        if (state.status == UserManagementStatus.loading && state.users.isEmpty) {
          content = const Center(child: CircularProgressIndicator());
        } else if (state.users.isEmpty) {
          content = Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.group_off, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No hay usuarios registrados', style: TextStyle(fontSize: 18, color: Colors.grey)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.read<UserManagementCubit>().loadUsers(),
                  child: const Text('Recargar'),
                ),
              ],
            ),
          );
        } else {
          content = RefreshIndicator(
            onRefresh: () async => context.read<UserManagementCubit>().loadUsers(),
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: state.users.length,
              itemBuilder: (context, index) {
                final user = state.users[index];
                final isSuperAdmin = user.rol == AppRole.superadmin;
                final currentUserUid = context.read<UserProfileCubit>().state.user?.uid;
                final isCurrentUser = user.uid == currentUserUid;

                return Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSuperAdmin ? Colors.purple.withOpacity(0.2) : Colors.blue.withOpacity(0.2),
                      child: Icon(
                        isSuperAdmin ? Icons.admin_panel_settings : Icons.person,
                        color: isSuperAdmin ? Colors.purple : Colors.blue,
                      ),
                    ),
                    title: Text('${user.nombre} ${user.apellido}', style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.email),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isSuperAdmin ? Colors.purple : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            user.rol.displayName.toUpperCase(),
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isSuperAdmin ? Colors.white : Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    trailing: isCurrentUser
                        ? const Tooltip(
                            message: 'No puedes modificar tu propia cuenta',
                            child: Icon(Icons.shield, color: Colors.grey),
                          )
                        : PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'role') {
                                _showRoleDialog(context, user);
                              } else if (value == 'delete') {
                                _showDeleteDialog(context, user);
                              }
                            },
                            itemBuilder: (context) => [
                              const PopupMenuItem(
                                value: 'role',
                                child: Row(
                                  children: [
                                    Icon(Icons.manage_accounts, size: 20),
                                    SizedBox(width: 8),
                                    Text('Cambiar Rol'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'delete',
                                child: Row(
                                  children: [
                                    Icon(Icons.delete, color: Colors.red, size: 20),
                                    SizedBox(width: 8),
                                    Text('Eliminar', style: TextStyle(color: Colors.red)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                    isThreeLine: true,
                  ),
                );
              },
            ),
          );
        }

        return Column(
          children: [
            searchBar,
            if (state.status == UserManagementStatus.loading && state.users.isNotEmpty)
              const LinearProgressIndicator(),
            Expanded(child: content),
          ],
        );
      },
    );
  }
}
