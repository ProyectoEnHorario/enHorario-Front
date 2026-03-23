import 'package:flutter/material.dart';

class RealAppPlaceholderPage extends StatelessWidget {
  const RealAppPlaceholderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('App real')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'Pantalla de prueba: aqui ira la aplicación real después del login.',
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }
}
