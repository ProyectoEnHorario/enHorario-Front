import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/auth/data/repositories/account_deletion_service.dart';
import 'package:enhorario/features/auth/presentation/bloc/delete_account_cubit.dart';
import 'package:enhorario/features/auth/presentation/pages/real_app_entry_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  String _userEmail = 'Cargando...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('user_email');
      setState(() {
        _userEmail = email ?? 'Sin información';
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _userEmail = 'Error al cargar datos';
        _isLoading = false;
      });
    }
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
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
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.of(context).pop();
              _confirmDeleteAccount();
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    if (!mounted) return;

    // Mostrar confirmación final
    final shouldDelete = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) => AlertDialog(
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
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancelar eliminación'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sí, eliminar todo'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !mounted) return;

    // Mostrar diálogo de progreso
    if (!context.mounted) return;

    late DeleteAccountCubit deleteAccountCubit;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        deleteAccountCubit = DeleteAccountCubit(
          AccountDeletionService(ApiClient()),
        );

        // Iniciar eliminación inmediatamente
        deleteAccountCubit.deleteAccount();

        return BlocProvider<DeleteAccountCubit>.value(
          value: deleteAccountCubit,
          child: BlocListener<DeleteAccountCubit, DeleteAccountState>(
            listener: (context, state) async {
              if (state.isDeleted) {
                // Éxito - cerrar diálogo
                Navigator.of(dialogContext).pop();

                // Limpiar datos locales
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                if (!context.mounted) return;

                // Mostrar confirmación
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Tu cuenta ha sido eliminada exitosamente'),
                    duration: Duration(seconds: 2),
                  ),
                );

                // Esperar y redirigir
                await Future.delayed(const Duration(seconds: 2));
                if (!context.mounted) return;

                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(
                    builder: (_) => const RealAppEntryScreen(),
                  ),
                  (_) => false,
                );
              }

              if (state.error != null) {
                // Error
                Navigator.of(dialogContext).pop();

                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: ${state.error}'),
                    backgroundColor: Colors.red,
                    duration: const Duration(seconds: 4),
                  ),
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
                    builder: (context, state) {
                      return Text(
                        state.isDeleting ? 'Por favor espera...' : 'Procesando...',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    ).then((_) {
      deleteAccountCubit.close();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const SizedBox(height: 24),
            // Avatar del usuario
            const CircleAvatar(
              radius: 50,
              child: Icon(Icons.person, size: 50),
            ),
            const SizedBox(height: 24),
            // Información de cuenta
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Información de cuenta',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Center(child: CircularProgressIndicator())
                    else
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Email',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _userEmail,
                            style: const TextStyle(fontSize: 16),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Icon(Icons.check_circle, color: Colors.green),
                              const SizedBox(width: 8),
                              const Text('Cuenta verificada'),
                            ],
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            // Sección de peligro - Eliminar cuenta
            Card(
              color: Colors.red.withOpacity(0.05),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.warning, color: Colors.red[700]),
                        const SizedBox(width: 8),
                        const Text(
                          'Zona de peligro',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Las acciones en esta sección no pueden deshacerse.',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.red,
                        ),
                        onPressed: _showDeleteAccountDialog,
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.delete_forever, size: 20),
                            SizedBox(width: 8),
                            Text('Eliminar mi cuenta'),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
