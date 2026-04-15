import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/auth/data/repositories/railway_password_repository.dart';
import 'package:enhorario/features/auth/presentation/bloc/password_cubit.dart';
import 'package:enhorario/features/auth/presentation/pages/reset_password_screen.dart';
import 'package:enhorario/features/auth/presentation/validators/register_form_validators.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _submit(BuildContext childContext) {
    if (_formKey.currentState?.validate() ?? false) {
      childContext.read<PasswordCubit>().forgotPassword(_emailController.text.trim());
    }
  }

  void _navigateToReset(BuildContext context, String? token) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => ResetPasswordScreen(
          prefilledToken: token,
          email: _emailController.text.trim(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => PasswordCubit(RailwayPasswordRepository(ApiClient())),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Recuperar contraseña'),
        ),
        body: BlocConsumer<PasswordCubit, PasswordState>(
          listener: (context, state) {
            if (state.status == PasswordStatus.success) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message ?? 'Solicitud enviada'),
                  backgroundColor: Colors.green,
                ),
              );
              _navigateToReset(context, state.resetToken);
            } else if (state.status == PasswordStatus.error) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error ?? 'Error general'),
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
                    const Icon(
                      Icons.mark_email_read_outlined,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      '¿Olvidaste tu contraseña?',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ingresa el correo electrónico asociado a tu cuenta y te enviaremos las instrucciones para restablecerla.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey, fontSize: 14),
                    ),
                    const SizedBox(height: 40),

                    // Correo Electrónico
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Correo electrónico',
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                      validator: (value) => RegisterFormValidators.validateEmail(value ?? ''),
                    ),
                    const SizedBox(height: 32),

                    // Botón Enviar
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
                          : const Text('Enviar Solicitud'),
                    ),

                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: isLoading ? null : () => _navigateToReset(context, null),
                      child: const Text('Ya tengo un código de acceso'),
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
