import 'package:enhorario/features/establishments/data/models/establishment_model.dart';
import 'package:flutter/material.dart';

class EstablishmentDetailScreen extends StatelessWidget {
  const EstablishmentDetailScreen({super.key, required this.item});

  final EstablishmentModel item;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle establecimiento')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('Nombre: ${item.nombre}'),
          Text('Nombre normalizado: ${item.nombreNormalizado}'),
          Text('Descripcion: ${item.descripcion ?? 'Sin descripcion'}'),
          Text('Direccion: ${item.direccion}'),
          Text('Category ID: ${item.categoryId}'),
          Text('Admin ID: ${item.adminId}'),
          Text('Activo: ${item.activo ? 'Si' : 'No'}'),
          Text('Abierto: ${item.abierto ? 'Si' : 'No'}'),
          Text('Creado: ${item.createdAt}'),
        ],
      ),
    );
  }
}
