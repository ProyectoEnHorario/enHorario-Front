import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/auth/data/repositories/auth_session_repository.dart';
import 'package:enhorario/features/auth/data/repositories/railway_login_account_service.dart';
import 'package:enhorario/features/auth/presentation/bloc/login_user_cubit.dart';
import 'package:enhorario/features/auth/presentation/pages/forgot_password_screen.dart';
import 'package:enhorario/features/auth/presentation/pages/register_user_screen.dart';
import 'package:enhorario/features/auth/presentation/validators/login_form_validators.dart';
import 'package:enhorario/features/home/presentation/pages/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginUserScreen extends StatefulWidget {
  const LoginUserScreen({super.key});

  @override
  State<LoginUserScreen> createState() => _LoginUserScreenState();
}

class _LoginUserScreenState extends State<LoginUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() != true) {
      return;
    }

    context.read<LoginUserCubit>().login(
      email: _emailCtrl.text.trim(),
      password: _passwordCtrl.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => LoginUserCubit(
        RailwayLoginAccountService(ApiClient()),
        AuthSessionRepository(),
      ),
      child: Scaffold(
        appBar: AppBar(title: const Text('Inicio de sesion')),
        body: BlocConsumer<LoginUserCubit, LoginUserState>(
          listener: (context, state) {
            if (!state.success) return;
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute<void>(
                builder: (_) => const MainNavigationScreen(),
              ),
              (_) => false,
            );
          },
          builder: (context, state) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Ingresa para acceder a tu cuenta EnHorario',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Correo electronico',
                        hintText: 'correo@dominio.com',
                      ),
                      validator: (value) =>
                          LoginFormValidators.validateEmail(value ?? ''),
                      onChanged: (_) =>
                          context.read<LoginUserCubit>().clearError(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Contrasena',
                      ),
                      validator: (value) =>
                          LoginFormValidators.validatePassword(value ?? ''),
                      onChanged: (_) =>
                          context.read<LoginUserCubit>().clearError(),
                    ),
                    const SizedBox(height: 12),
                    if (state.generalError != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          state.generalError!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        ),
                      ),
                    SizedBox(
                      height: 48,
                      child: FilledButton(
                        onPressed: state.isSubmitting
                            ? null
                            : () => _submit(context),
                        child: state.isSubmitting
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text('Iniciar sesion'),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const ForgotPasswordScreen(),
                                ),
                              );
                            },
                      child: const Text('¿Olvidaste tu contraseña?'),
                    ),
                    TextButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const RegisterUserScreen(),
                                ),
                              );
                            },
                      child: const Text('No tengo cuenta, quiero registrarme'),
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
