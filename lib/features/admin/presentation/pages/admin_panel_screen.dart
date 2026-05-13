import 'package:flutter/material.dart';
import 'package:enhorario/features/admin/presentation/pages/user_management_screen.dart';
import 'package:enhorario/features/admin/presentation/pages/establishment_management_screen.dart';
import 'package:enhorario/core/navigation/role_guard.dart';
import 'package:enhorario/core/enums/app_role.dart';

import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/auth/data/repositories/railway_user_repository.dart';
import 'package:enhorario/features/auth/presentation/bloc/user_management_cubit.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:enhorario/features/admin/presentation/widgets/admin_establishment_list_view.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requirement: (role) => role.canManageUsers,
      child: BlocProvider(
        create: (context) => UserManagementCubit(
          RailwayUserRepository(context.read<ApiClient>()),
        )..loadUsers(),
        child: DefaultTabController(
          length: 3,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Panel de Administración'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.people), text: 'Usuarios'),
                Tab(icon: Icon(Icons.store), text: 'Locales'),
                Tab(icon: Icon(Icons.manage_accounts), text: 'Admins'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              UserManagementScreen(),
              EstablishmentManagementScreen(),
              AdminEstablishmentListView(),
            ],
          ),
        ),
      ),
    );
  }
}
