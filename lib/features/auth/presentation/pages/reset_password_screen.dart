import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/auth/data/repositories/railway_password_repository.dart';
import 'package:enhorario/features/auth/presentation/bloc/password_cubit.dart';
import 'package:enhorario/features/auth/presentation/validators/register_form_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({
    super.key,
    this.prefilledToken,
    this.email,
  });

  /// Token opcional pre-llenado (útil si el backend lo mandó en el response anterior).
  final String? prefilledToken;
  
  /// Email de quien solicita, solo para mostrarlo por contexto.
  final String? email;

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _tokenController;
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  @override
  void initState() {
    super.initState();
    _tokenController = TextEditingController(text: widget.prefilledToken ?? '');
  }

  @override
  void dispose() {
    _tokenController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _submit(BuildContext childContext) {
    if (_formKey.currentState?.validate() ?? false) {
      childContext.read<PasswordCubit>().resetPassword(
            token: _tokenController.text.trim(),
            newPassword: _newPasswordController.text,
            confirmNewPassword: _confirmPasswordController.text,
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return BlocProvider(
      create: (context) => PasswordCubit(RailwayPasswordRepository(ApiClient())),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Restablecer contraseña'),
        ),
        body: BlocConsumer<PasswordCubit, PasswordState>(
          listener: (context, state) {
            if (state.status == PasswordStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message ?? 'Contraseña restablecida exitosamente'),
                  backgroundColor: Colors.green,
                ),
              );
              Navigator.of(context).popUntil((route) => route.isFirst);
            } else if (state.status == PasswordStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error ?? 'Error al restablecer contraseña'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          },
          builder: (context, state) {
            final isLoading = state.status == PasswordStatus.loading;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (widget.email != null) ...[
                      Text(
                        'Hemos enviado las instrucciones a:',
                        style: textTheme.bodyMedium?.copyWith(color: Colors.grey),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.email!,
                        style: textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 32),
                    ],

                    // Token
                    TextFormField(
                      controller: _tokenController,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Código de verificación / Token',
                        prefixIcon: Icon(Icons.key_outlined),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'El código es obligatorio.';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Nueva Contraseña
                    TextFormField(
                      controller: _newPasswordController,
                      obscureText: _obscureNew,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: 'Nueva contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNew ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscureNew = !_obscureNew),
                        ),
                      ),
                      validator: (value) => RegisterFormValidators.validatePassword(value ?? ''),
                    ),
                    const SizedBox(height: 16),

                    // Confirmar Nueva Contraseña
                    TextFormField(
                      controller: _confirmPasswordController,
                      obscureText: _obscureConfirm,
                      enabled: !isLoading,
                      decoration: InputDecoration(
                        labelText: 'Confirmar nueva contraseña',
                        prefixIcon: const Icon(Icons.lock_outline),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                          ),
                          onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
                        ),
                      ),
                      validator: (value) => RegisterFormValidators.validateConfirmPassword(
                        password: _newPasswordController.text,
                        confirmPassword: value ?? '',
                      ),
                    ),
                    const SizedBox(height: 48),

                    // Botón Guardar
                    FilledButton(
                      onPressed: isLoading ? null : () => _submit(context),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Guardar y Entrar'),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
