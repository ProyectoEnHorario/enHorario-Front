import 'package:flutter/material.dart';

class LoginSelectionPage extends StatelessWidget {
  const LoginSelectionPage({
    super.key,
    required this.onEnterRealApp,
    required this.onEnterTestMode,
  });

  final VoidCallback onEnterRealApp;
  final VoidCallback onEnterTestMode;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ingreso')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  'Selecciona el modo de acceso',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 12),
                Text(
                  'Modo real disponible en construcción. El modo test carga la app actual con CRUDs.',
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: onEnterRealApp,
                  child: const Text('Iniciar sesión (App real)'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: onEnterTestMode,
                  child: const Text('Entrar en modo test'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
