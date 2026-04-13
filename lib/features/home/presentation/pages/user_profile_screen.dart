import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/auth/data/repositories/account_deletion_service.dart';
import 'package:enhorario/features/auth/presentation/bloc/delete_account_cubit.dart';
import 'package:enhorario/features/auth/presentation/bloc/user_profile_cubit.dart';
import 'package:enhorario/features/auth/presentation/pages/real_app_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<UserProfileCubit, UserProfileState>(
      builder: (context, state) {
        if (state.isLoading && state.user == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state.error != null && state.user == null) {
          return _ErrorState(
            message: state.error!,
            onRetry: () => context.read<UserProfileCubit>().loadProfile(),
          );
        }

        final user = state.user;

        return RefreshIndicator(
          onRefresh: () => context.read<UserProfileCubit>().loadProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              children: [
                _ProfileHeader(
                  name: user != null ? '${user.nombre} ${user.apellido}' : 'Usuario',
                  role: user?.rol ?? 'Cargando...',
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _ProfileInfoSection(
                        title: 'Información Personal',
                        items: [
                          _ProfileInfoItem(
                            icon: Icons.person_outline,
                            label: 'Nombre',
                            value: user?.nombre ?? '---',
                          ),
                          _ProfileInfoItem(
                            icon: Icons.person_outline,
                            label: 'Apellido',
                            value: user?.apellido ?? '---',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _ProfileInfoSection(
                        title: 'Contacto',
                        items: [
                          _ProfileInfoItem(
                            icon: Icons.email_outlined,
                            label: 'Email',
                            value: user?.email ?? '---',
                          ),
                          _ProfileInfoItem(
                            icon: Icons.phone_outlined,
                            label: 'Teléfono',
                            value: user?.telefono ?? 'No registrado',
                          ),
                        ],
                      ),
                      const SizedBox(height: 32),
                      _DangerZone(
                        onDeleteAccount: () => _showDeleteAccountDialog(context),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteAccountDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Eliminar cuenta'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Advertencia importante:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 12),
              Text(
                '• Tu cuenta será eliminada permanentemente\n'
                '• Se perderá todo tu historial y datos\n'
                '• Los turnos activos serán cancelados\n'
                '• Tu sesión se cerrará inmediatamente\n'
                '• No podrás recuperar tu cuenta después\n'
                '• Esta acción es irreversible',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                '¿Deseas continuar?',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(dialogContext).pop();
              _confirmDeleteAccount(context);
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount(BuildContext context) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Confirmación final'),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Esta es la última oportunidad para cancelar.',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
            ),
            SizedBox(height: 12),
            Text('Se eliminarán definitivamente:'),
            Text('• Tu cuenta y datos personales'),
            Text('• Tu historial completo'),
            Text('• Todos tus tickets'),
            SizedBox(height: 12),
            Text(
              'No podrá deshacer esto.',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancelar eliminación'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sí, eliminar todo'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;

    _executeAccountDeletion(context);
  }

  void _executeAccountDeletion(BuildContext context) {
    late DeleteAccountCubit deleteAccountCubit;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        deleteAccountCubit = DeleteAccountCubit(
          AccountDeletionService(ApiClient()),
        );

        deleteAccountCubit.deleteAccount();

        return BlocProvider<DeleteAccountCubit>.value(
          value: deleteAccountCubit,
          child: BlocListener<DeleteAccountCubit, DeleteAccountState>(
            listener: (context, state) async {
              if (state.isDeleted) {
                Navigator.of(dialogContext).pop();
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Tu cuenta ha sido eliminada exitosamente')),
                );

                await Future.delayed(const Duration(seconds: 2));
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: (_) => const RealAppEntryScreen()),
                  (_) => false,
                );
              }

              if (state.error != null) {
                Navigator.of(dialogContext).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error: ${state.error}'), backgroundColor: Colors.red),
                );
              }
            },
            child: AlertDialog(
              title: const Text('Eliminando tu cuenta'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 16),
                  BlocBuilder<DeleteAccountCubit, DeleteAccountState>(
                    builder: (context, state) => Text(
                      state.isDeleting ? 'Por favor espera...' : 'Procesando...',
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) => deleteAccountCubit.close());
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.name, required this.role});

  final String name;
  final String role;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            theme.colorScheme.primary.withOpacity(0.8),
            theme.colorScheme.primary,
          ],
        ),
      ),
      padding: const EdgeInsets.only(top: 40, bottom: 24),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: Colors.white.withOpacity(0.2),
            child: const Icon(Icons.person, size: 60, color: Colors.white),
          ),
          const SizedBox(height: 16),
          Text(
            name,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              role.toUpperCase(),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.1,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileInfoSection extends StatelessWidget {
  const _ProfileInfoSection({required this.title, required this.items});

  final String title;
  final List<_ProfileInfoItem> items;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: items,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileInfoItem extends StatelessWidget {
  const _ProfileInfoItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 24),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DangerZone extends StatelessWidget {
  const _DangerZone({required this.onDeleteAccount});

  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context) {
    return Card(
      color: Colors.red.withOpacity(0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.red.withOpacity(0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.warning_amber_rounded, color: Colors.red),
                SizedBox(width: 8),
                Text(
                  'Zona de Peligro',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Eliminar tu cuenta borrará permanentemente toda tu información.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                onPressed: onDeleteAccount,
                icon: const Icon(Icons.delete_forever),
                label: const Text('Eliminar Mi Cuenta'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: Colors.red, size: 60),
          const SizedBox(height: 16),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          ElevatedButton(onPressed: onRetry, child: const Text('Reintentar')),
        ],
      ),
    );
  }
}
