import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/core/config/app_config.dart';
import 'package:enhorario/core/services/afluencia_monitor_service.dart';
import 'package:enhorario/core/services/notification_payload.dart';
import 'package:enhorario/core/services/notification_service.dart';
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

  // Estado de notificaciones
  bool _notificationsEnabled = true;
  double _cooldownMinutes = 120;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(AppConfig.userKey);
      
      // Cargar configuraciones de notificación
      final enabled = prefs.getBool(AppConfig.notificationsEnabledKey) ?? true;
      final cooldown = prefs.getInt(AppConfig.notificationCooldownKey)?.toDouble() ?? 120.0;

      setState(() {
        _userEmail = email ?? 'Sin información';
        _notificationsEnabled = enabled;
        _cooldownMinutes = cooldown;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() {
          _userEmail = 'Error al cargar datos';
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _toggleNotifications(bool value) async {
    if (value) {
      // Solicitar permisos al activar (ENH-155)
      final granted = await NotificationService().requestPermissions();
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Permisos de notificación denegados. Por favor, actívalos en los ajustes del sistema.',
            ),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(AppConfig.notificationsEnabledKey, value);

    setState(() {
      _notificationsEnabled = value;
    });

    if (value) {
      AfluenciaMonitorService().startMonitoring();
    } else {
      AfluenciaMonitorService().stopMonitoring();
    }
  }

  Future<void> _updateCooldown(double value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConfig.notificationCooldownKey, value.round());
    
    setState(() {
      _cooldownMinutes = value;
    });
  }

  String _formatCooldownText(double minutes) {
    if (minutes < 60) return 'Cada ${minutes.round()} minutos';
    final hours = minutes / 60;
    if (hours == 1) return 'Cada 1 hora';
    return 'Cada ${hours.toStringAsFixed(1).replaceAll('.0', '')} horas';
  }

  void _showDeleteAccountDialog() {
    // ...
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
            _buildAccountInfoCard(),
            const SizedBox(height: 16),
            
            // --- NUEVA SECCIÓN DE NOTIFICACIONES (ENH-154) ---
            _buildNotificationSettingsCard(),
            
            const SizedBox(height: 32),
            // Sección de peligro - Eliminar cuenta
            _buildDangerZoneCard(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildAccountInfoCard() {
    return Card(
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
                  const Row(
                    children: [
                      Icon(Icons.check_circle, color: Colors.green),
                      SizedBox(width: 8),
                      Text('Cuenta verificada'),
                    ],
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotificationSettingsCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Notificaciones de afluencia',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Alertas de baja afluencia'),
              subtitle: const Text('Recibe notificaciones sobre locales cercanos'),
              value: _notificationsEnabled,
              onChanged: _toggleNotifications,
            ),
            if (_notificationsEnabled) ...[
              const Divider(),
              const SizedBox(height: 8),
              const Text(
                'Frecuencia de las alertas',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Tiempo mínimo entre una notificación y otra para el mismo local.',
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('5 min'),
                  Text(
                    _formatCooldownText(_cooldownMinutes),
                    style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('5 horas'),
                ],
              ),
              Slider(
                value: _cooldownMinutes,
                min: 5,
                max: 300,
                divisions: 59, // Pasos de 5 minutos
                onChanged: _updateCooldown,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDangerZoneCard() {
    return Card(
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
    );
  }
}
