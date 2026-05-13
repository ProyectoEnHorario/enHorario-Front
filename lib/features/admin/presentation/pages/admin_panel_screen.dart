import 'package:flutter/material.dart';
import 'package:enhorario/features/admin/presentation/pages/user_management_screen.dart';
import 'package:enhorario/features/admin/presentation/pages/establishment_management_screen.dart';
import 'package:enhorario/core/navigation/role_guard.dart';
import 'package:enhorario/core/enums/app_role.dart';

class AdminPanelScreen extends StatelessWidget {
  const AdminPanelScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RoleGuard(
      requirement: (role) => role.canManageUsers,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Panel de Administración'),
            bottom: const TabBar(
              tabs: [
                Tab(icon: Icon(Icons.people), text: 'Usuarios'),
                Tab(icon: Icon(Icons.store), text: 'Locales'),
              ],
            ),
          ),
          body: const TabBarView(
            children: [
              UserManagementScreen(),
              EstablishmentManagementScreen(),
            ],
          ),
        ),
      ),
    );
  }
}
