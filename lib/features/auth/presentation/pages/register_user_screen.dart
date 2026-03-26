import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/auth/data/repositories/railway_register_account_service.dart';
import 'package:enhorario/features/auth/domain/repositories/register_account_service.dart';
import 'package:enhorario/features/auth/presentation/bloc/register_user_cubit.dart';
import 'package:enhorario/features/auth/presentation/pages/login_user_screen.dart';
import 'package:enhorario/features/auth/presentation/validators/register_form_validators.dart';
import 'package:enhorario/features/home/presentation/pages/main_navigation_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class RegisterUserScreen extends StatefulWidget {
  const RegisterUserScreen({super.key});

  @override
  State<RegisterUserScreen> createState() => _RegisterUserScreenState();
}

class _RegisterUserScreenState extends State<RegisterUserScreen> {
  final _formKey = GlobalKey<FormState>();
  final RegisterAccountService _registerService = RailwayRegisterAccountService(
    ApiClient(),
  );

  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmPasswordCtrl = TextEditingController();

  bool _acceptTerms = true;

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmPasswordCtrl.dispose();
    super.dispose();
  }

  void _submit(BuildContext context) {
    FocusScope.of(context).unfocus();

    if (_formKey.currentState?.validate() != true) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Debes aceptar los terminos para continuar.'),
        ),
      );
      return;
    }

    context.read<RegisterUserCubit>().submit(
      RegisterAccountRequest(
        nombre: _nombreCtrl.text.trim(),
        apellido: _apellidoCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        password: _passwordCtrl.text,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => RegisterUserCubit(_registerService),
      child: Scaffold(
        appBar: AppBar(title: const Text('Registro de usuarios')),
        body: BlocConsumer<RegisterUserCubit, RegisterUserState>(
          listener: (context, state) {
            if (state.successMessage != null) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.successMessage!)));

              Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(
                  builder: (_) => const MainNavigationScreen(),
                ),
              );
            }
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
                      'Crea tu cuenta para entrar a EnHorario',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _nombreCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        hintText: 'Ejemplo: Ana',
                      ),
                      validator: (value) =>
                          RegisterFormValidators.validateNombre(value ?? ''),
                      onChanged: (_) =>
                          context.read<RegisterUserCubit>().clearFeedback(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _apellidoCtrl,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Apellido',
                        hintText: 'Ejemplo: Perez',
                      ),
                      validator: (value) =>
                          RegisterFormValidators.validateApellido(value ?? ''),
                      onChanged: (_) =>
                          context.read<RegisterUserCubit>().clearFeedback(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _emailCtrl,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: InputDecoration(
                        labelText: 'Correo electronico',
                        hintText: 'correo@dominio.com',
                        errorText: state.emailError,
                      ),
                      validator: (value) =>
                          RegisterFormValidators.validateEmail(value ?? ''),
                      onChanged: (_) =>
                          context.read<RegisterUserCubit>().clearFeedback(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _passwordCtrl,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        labelText: 'Contrasena',
                        hintText: 'Minimo 8 caracteres',
                      ),
                      validator: (value) =>
                          RegisterFormValidators.validatePassword(value ?? ''),
                      onChanged: (_) =>
                          context.read<RegisterUserCubit>().clearFeedback(),
                    ),
                    const SizedBox(height: 12),
                    TextFormField(
                      controller: _confirmPasswordCtrl,
                      obscureText: true,
                      enableSuggestions: false,
                      autocorrect: false,
                      textInputAction: TextInputAction.done,
                      decoration: const InputDecoration(
                        labelText: 'Confirmar contrasena',
                      ),
                      validator: (value) =>
                          RegisterFormValidators.validateConfirmPassword(
                            password: _passwordCtrl.text,
                            confirmPassword: value ?? '',
                          ),
                      onChanged: (_) =>
                          context.read<RegisterUserCubit>().clearFeedback(),
                    ),
                    const SizedBox(height: 10),
                    CheckboxListTile(
                      contentPadding: EdgeInsets.zero,
                      value: _acceptTerms,
                      onChanged: state.isSubmitting
                          ? null
                          : (value) {
                              setState(() {
                                _acceptTerms = value ?? false;
                              });
                            },
                      title: const Text('Acepto terminos y condiciones'),
                      controlAffinity: ListTileControlAffinity.leading,
                    ),
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
                            : const Text('Registrarme'),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton(
                      onPressed: state.isSubmitting
                          ? null
                          : () {
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute<void>(
                                  builder: (_) => const LoginUserScreen(),
                                ),
                              );
                            },
                      child: const Text('Ya tengo cuenta'),
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
