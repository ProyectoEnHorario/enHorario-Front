import 'package:enhorario/features/establishments/data/models/establishment_model.dart';
import 'package:enhorario/features/establishments/data/repositories/firestore_establishment_repository.dart';
import 'package:enhorario/features/establishments/presentation/bloc/establishments_cubit.dart';
import 'package:enhorario/features/establishments/presentation/pages/establishment_detail_screen.dart';
import 'package:enhorario/features/establishments/presentation/pages/establishment_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class EstablishmentsScreen extends StatelessWidget {
  const EstablishmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EstablishmentsCubit(FirestoreEstablishmentRepository()),
      child: const _EstablishmentsView(),
    );
  }
}

class _EstablishmentsView extends StatelessWidget {
  const _EstablishmentsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Establecimientos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => EstablishmentFormScreen(
                onSave: context.read<EstablishmentsCubit>().create,
              ),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Buscar por nombre',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: context.read<EstablishmentsCubit>().setQuery,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'Filtrar por categoryId',
              ),
              onChanged: (v) => context
                  .read<EstablishmentsCubit>()
                  .setCategoryFilter(v.trim().isEmpty ? null : v.trim()),
            ),
          ),
          Expanded(
            child: BlocBuilder<EstablishmentsCubit, EstablishmentsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null) {
                  return Center(child: Text(state.error!));
                }
                if (state.filtered.isEmpty) {
                  return const Center(
                    child: Text('No hay establecimientos para mostrar'),
                  );
                }
                return ListView.builder(
                  itemCount: state.filtered.length,
                  itemBuilder: (context, index) {
                    final item = state.filtered[index];
                    return ListTile(
                      title: Text(item.nombre),
                      subtitle: Text(
                        '${item.categoryId} - ${item.abierto ? 'Abierto' : 'Cerrado'}',
                      ),
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) =>
                                EstablishmentDetailScreen(item: item),
                          ),
                        );
                      },
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => EstablishmentFormScreen(
                                    initial: item,
                                    onSave: context
                                        .read<EstablishmentsCubit>()
                                        .update,
                                  ),
                                ),
                              );
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _confirmDelete(context, item),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    EstablishmentModel item,
  ) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Confirmar eliminacion'),
        content: Text('Eliminar establecimiento ${item.nombre}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
    if (ok != true || !context.mounted) return;

    final error = await context.read<EstablishmentsCubit>().delete(item.id);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(error ?? 'Establecimiento eliminado')),
    );
  }
}
