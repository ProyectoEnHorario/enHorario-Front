import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/core/config/app_config.dart';
import 'package:enhorario/features/auth/data/repositories/account_deletion_service.dart';
import 'package:enhorario/features/auth/presentation/bloc/delete_account_cubit.dart';
import 'package:enhorario/features/auth/presentation/bloc/user_profile_cubit.dart';
import 'package:enhorario/features/auth/presentation/pages/change_password_screen.dart';
import 'package:enhorario/features/auth/presentation/pages/real_app_entry_screen.dart';
import 'package:enhorario/features/notifications/presentation/bloc/notifications_cubit.dart';
import 'package:enhorario/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:enhorario/features/auth/presentation/validators/register_form_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserProfileScreen extends StatefulWidget {
  const UserProfileScreen({super.key});

  @override
  State<UserProfileScreen> createState() => _UserProfileScreenState();
}

class _UserProfileScreenState extends State<UserProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nombreController;
  late TextEditingController _apellidoController;
  late TextEditingController _telefonoController;
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _nombreController = TextEditingController();
    _apellidoController = TextEditingController();
    _telefonoController = TextEditingController();
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _telefonoController.dispose();
    super.dispose();
  }

  void _initControllers(UserProfileState state) {
    if (state.user != null && _nombreController.text.isEmpty) {
      _nombreController.text = state.user!.nombre;
      _apellidoController.text = state.user!.apellido;
      _telefonoController.text = state.user!.telefono ?? '';
    }
  }

  Future<void> _pickPhoto(BuildContext context, ImageSource source) async {
    Navigator.of(context).pop(); // Cierra el bottom sheet
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (pickedFile == null || !context.mounted) return;

      await context.read<UserProfileCubit>().uploadProfilePhoto(pickedFile.path);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil actualizada'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error al seleccionar foto: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showPhotoOptions(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                'Cambiar foto de perfil',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              ListTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: const Text('Elegir de la galería'),
                onTap: () => _pickPhoto(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt_outlined),
                title: const Text('Tomar una foto'),
                onTap: () => _pickPhoto(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.close, color: Colors.red),
                title: const Text('Cancelar', style: TextStyle(color: Colors.red)),
                onTap: () => Navigator.of(sheetContext).pop(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<UserProfileCubit, UserProfileState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
          context.read<UserProfileCubit>().clearError();
        }
      },
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

        _initControllers(state);
        final user = state.user;

        return RefreshIndicator(
          onRefresh: () => context.read<UserProfileCubit>().loadProfile(),
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  _ProfileHeader(
                    name: user != null ? '${user.nombre} ${user.apellido}' : 'Usuario',
                    role: user?.rol.displayName ?? 'Cargando...',
                    profilePhotoUrl: user?.profilePhotoUrl,
                    isEditing: state.isEditing,
                    isUploadingPhoto: state.isUploadingPhoto,
                    onPhotoTap: () => _showPhotoOptions(context),
                    onEdit: () => context.read<UserProfileCubit>().startEditing(),
                    onCancel: () {
                      _formKey.currentState?.reset();
                      _nombreController.text = user?.nombre ?? '';
                      _apellidoController.text = user?.apellido ?? '';
                      _telefonoController.text = user?.telefono ?? '';
                      context.read<UserProfileCubit>().cancelEditing();
                    },
                    onSave: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        context.read<UserProfileCubit>().updateProfile(
                          nombre: _nombreController.text.trim(),
                          apellido: _apellidoController.text.trim(),
                          telefono: _telefonoController.text.trim(),
                        );
                      }
                    },
                    isLoading: state.isLoading,
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
                              isEditing: state.isEditing,
                              controller: _nombreController,
                              validator: (v) => RegisterFormValidators.validateNombre(v ?? ''),
                            ),
                            _ProfileInfoItem(
                              icon: Icons.person_outline,
                              label: 'Apellido',
                              value: user?.apellido ?? '---',
                              isEditing: state.isEditing,
                              controller: _apellidoController,
                              validator: (v) => RegisterFormValidators.validateApellido(v ?? ''),
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
                              isEditing: false,
                            ),
                            _ProfileInfoItem(
                              icon: Icons.phone_outlined,
                              label: 'Teléfono',
                              value: user?.telefono ?? 'No registrado',
                              isEditing: state.isEditing,
                              controller: _telefonoController,
                              keyboardType: TextInputType.phone,
                              validator: (v) => RegisterFormValidators.validatePhone(v ?? ''),
                            ),
                          ],
                        ),
                        if (!state.isEditing) ...[
                          const SizedBox(height: 32),
                          _SecuritySection(
                            onChangePassword: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const ChangePasswordScreen(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          // Configuración de notificaciones
                          BlocBuilder<NotificationsCubit, NotificationsState>(
                            builder: (context, notifState) {
                              return Card(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Padding(
                                        padding: EdgeInsets.fromLTRB(16, 8, 16, 0),
                                        child: Text(
                                          'Notificaciones',
                                          style: TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      SwitchListTile(
                                        title: const Text('Baja afluencia en favoritos'),
                                        subtitle: const Text(
                                          'Recibe alertas cuando un lugar que te gusta tenga poca fila.',
                                          style: TextStyle(fontSize: 12),
                                        ),
                                        secondary: const Icon(Icons.notifications_active_outlined),
                                        value: notifState.isNotificationsEnabled,
                                        onChanged: (value) {
                                          context.read<NotificationsCubit>().toggleNotifications(value);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: 32),
                          _DangerZone(
                            onDeleteAccount: () => _showDeleteAccountDialog(context),
                          ),
                        ],
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ],
              ),
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
            style: FilledButton.styleFrom(backgroundColor: Theme.of(dialogContext).colorScheme.error),
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
            style: FilledButton.styleFrom(backgroundColor: Theme.of(dialogContext).colorScheme.error),
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

// ---------------------------------------------------------------------------
// Widgets Privados
// ---------------------------------------------------------------------------

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.name,
    required this.role,
    required this.isEditing,
    required this.isUploadingPhoto,
    required this.onPhotoTap,
    this.profilePhotoUrl,
    this.onEdit,
    this.onCancel,
    this.onSave,
    this.isLoading = false,
  });

  final String name;
  final String role;
  final bool isEditing;
  final bool isUploadingPhoto;
  final VoidCallback onPhotoTap;
  final String? profilePhotoUrl;
  final VoidCallback? onEdit;
  final VoidCallback? onCancel;
  final VoidCallback? onSave;
  final bool isLoading;

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
      padding: const EdgeInsets.only(top: 20, bottom: 24),
      child: Column(
        children: [
          Stack(
            children: [
              // Avatar: foto personalizada o icono por defecto
              CircleAvatar(
                radius: 50,
                backgroundColor: Colors.white.withOpacity(0.2),
                backgroundImage: profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty
                    ? NetworkImage(_resolveImageUrl(profilePhotoUrl!))
                    : null,
                child: isUploadingPhoto
                    ? const CircularProgressIndicator(color: Colors.white, strokeWidth: 3)
                    : (profilePhotoUrl == null || profilePhotoUrl!.isEmpty)
                        ? const Icon(Icons.person, size: 60, color: Colors.white)
                        : null,
              ),
              // Botón de editar foto (siempre visible, no solo en modo edición)
              Positioned(
                right: 0,
                bottom: 0,
                child: GestureDetector(
                  onTap: isUploadingPhoto ? null : onPhotoTap,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                    child: const Icon(
                      Icons.camera_alt,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              // Botón de editar información (lápiz) cuando no se está editando
              if (!isEditing)
                Positioned(
                  right: 0,
                  top: 0,
                  child: FloatingActionButton.small(
                    elevation: 2,
                    onPressed: onEdit,
                    child: const Icon(Icons.edit, size: 18),
                  ),
                ),
            ],
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
          if (isEditing) ...[
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white),
                      ),
                      onPressed: isLoading ? null : onCancel,
                      child: const Text('Cancelar'),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onSave,
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Guardar'),
                    ),
                  ),
                ],
              ),
            ),
          ],
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
    required this.isEditing,
    this.controller,
    this.validator,
    this.keyboardType,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool isEditing;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
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
                if (isEditing && controller != null)
                  TextFormField(
                    controller: controller,
                    validator: validator,
                    keyboardType: keyboardType,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 8),
                    ),
                  )
                else
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

class _SecuritySection extends StatelessWidget {
  const _SecuritySection({required this.onChangePassword});

  final VoidCallback onChangePassword;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Row(
              children: [
                Icon(Icons.security, color: Colors.grey),
                SizedBox(width: 8),
                Text(
                  'Seguridad',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            const Text(
              'Actualiza tu contraseña para mantener tu cuenta segura.',
              style: TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onChangePassword,
                icon: const Icon(Icons.password),
                label: const Text('Cambiar Contraseña'),
              ),
            ),
          ],
        ),
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
                style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
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

String _resolveImageUrl(String url) {
  if (url.startsWith('http')) return url;
  
  try {
    final uri = Uri.parse(AppConfig.backendBaseUrl);
    final baseUrl = '${uri.scheme}://${uri.host}';
    final portString = (uri.port != 80 && uri.port != 443 && uri.port != 0) ? ':${uri.port}' : '';
    
    final path = url.startsWith('/') ? url : '/$url';
    return '$baseUrl$portString$path';
  } catch (e) {
    return url;
  }
}
