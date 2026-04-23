import 'package:enhorario/features/establishments/data/models/establishment_model.dart';
import 'package:enhorario/features/establishments/data/repositories/firestore_establishment_repository.dart';
import 'package:enhorario/features/establishments/presentation/bloc/establishments_cubit.dart';
import 'package:enhorario/features/establishments/presentation/pages/pantalla_detalle_establecimiento.dart';
import 'package:enhorario/features/establishments/presentation/pages/pantalla_formulario_establecimiento.dart';
import 'package:enhorario/features/establishments/presentation/widgets/establishment_search_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class PantallaEstablecimientos extends StatelessWidget {
  const PantallaEstablecimientos({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => EstablishmentsCubit(FirestoreEstablishmentRepository()),
      child: const _VistaEstablecimientos(),
    );
  }
}

class _VistaEstablecimientos extends StatelessWidget {
  const _VistaEstablecimientos();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Establecimientos')),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => PantallaFormularioEstablecimiento(
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
            child: BlocBuilder<EstablishmentsCubit, EstablishmentsState>(
              builder: (context, state) => EstablishmentSearchField(
                value: state.query,
                onChanged: context.read<EstablishmentsCubit>().setQuery,
                onClear: () => context.read<EstablishmentsCubit>().setQuery(''),
              ),
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
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(state.error!, textAlign: TextAlign.center),
                          const SizedBox(height: 12),
                          FilledButton(
                            onPressed: context
                                .read<EstablishmentsCubit>()
                                .retrySearch,
                            child: const Text('Reintentar'),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (state.filtered.isEmpty) {
                  final hasSearch =
                      state.query.trim().isNotEmpty ||
                      (state.categoryId?.isNotEmpty ?? false);
                  return Center(
                    child: Text(
                      hasSearch
                          ? 'No se encontraron establecimientos con ese nombre'
                          : 'No hay establecimientos para mostrar',
                      textAlign: TextAlign.center,
                    ),
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
                                PantallaDetalleEstablecimiento(item: item),
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
                                  builder: (_) => PantallaFormularioEstablecimiento(
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
