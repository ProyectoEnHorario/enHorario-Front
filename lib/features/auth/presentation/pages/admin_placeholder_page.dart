import 'package:flutter/material.dart';

class AdminPlaceholderPage extends StatelessWidget {
  const AdminPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administrador')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Pantalla de prueba: aqui iran estadisticas y administracion de locales/categorias.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
