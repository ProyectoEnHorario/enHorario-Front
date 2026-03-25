import 'package:enhorario/features/afluencia_stats/data/models/afluencia_stat_model.dart';
import 'package:enhorario/features/afluencia_stats/data/repositories/firestore_afluencia_stats_repository.dart';
import 'package:enhorario/features/afluencia_stats/presentation/bloc/afluencia_stats_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AfluenciaStatsScreen extends StatelessWidget {
  const AfluenciaStatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => AfluenciaStatsCubit(FirestoreAfluenciaStatsRepository()),
      child: const _AfluenciaStatsView(),
    );
  }
}

class _AfluenciaStatsView extends StatefulWidget {
  const _AfluenciaStatsView();

  @override
  State<_AfluenciaStatsView> createState() => _AfluenciaStatsViewState();
}

class _AfluenciaStatsViewState extends State<_AfluenciaStatsView> {
  String? _periodo;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Estadisticas de afluencia')),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: DropdownButtonFormField<String>(
              initialValue: _periodo,
              decoration: const InputDecoration(
                labelText: 'Filtrar por periodo',
              ),
              items: const [
                DropdownMenuItem(value: 'diario', child: Text('Diario')),
                DropdownMenuItem(value: 'semanal', child: Text('Semanal')),
                DropdownMenuItem(value: 'mensual', child: Text('Mensual')),
              ],
              onChanged: (value) {
                setState(() => _periodo = value);
                context.read<AfluenciaStatsCubit>().setPeriodo(value);
              },
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton(
                onPressed: () async {
                  final from = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now(),
                  );
                  if (!context.mounted) return;
                  context.read<AfluenciaStatsCubit>().setRango(
                    from,
                    context.read<AfluenciaStatsCubit>().state.to,
                  );
                },
                child: const Text('Fecha inicio'),
              ),
              TextButton(
                onPressed: () async {
                  final to = await showDatePicker(
                    context: context,
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2100),
                    initialDate: DateTime.now(),
                  );
                  if (!context.mounted) return;
                  context.read<AfluenciaStatsCubit>().setRango(
                    context.read<AfluenciaStatsCubit>().state.from,
                    to,
                  );
                },
                child: const Text('Fecha fin'),
              ),
              TextButton(
                onPressed: () {
                  context.read<AfluenciaStatsCubit>().setRango(null, null);
                },
                child: const Text('Limpiar rango'),
              ),
            ],
          ),
          Expanded(
            child: BlocBuilder<AfluenciaStatsCubit, AfluenciaStatsState>(
              builder: (context, state) {
                if (state.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state.error != null) {
                  return Center(child: Text(state.error!));
                }
                if (state.filtered.isEmpty) {
                  return const Center(
                    child: Text('No hay estadisticas para mostrar'),
                  );
                }
                return ListView.builder(
                  itemCount: state.filtered.length,
                  itemBuilder: (_, index) {
                    final item = state.filtered[index];
                    return ListTile(
                      title: Text(
                        'Establecimiento: ${item.establishmentId} (${item.periodo})',
                      ),
                      subtitle: Text(
                        'Total: ${item.totalTurnos} - Prioritarios: ${item.turnosPrioritarios}',
                      ),
                      trailing: Text(
                        item.fechaHora.toLocal().toString().split('.').first,
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

  Future<void> _showCreateDialog(BuildContext context) async {
    final establishmentController = TextEditingController();
    final categoryController = TextEditingController();
    final totalController = TextEditingController();
    final priorityController = TextEditingController();
    String periodo = 'diario';

    final ok = await showDialog<bool>(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Nueva estadistica'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: establishmentController,
                  decoration: const InputDecoration(
                    labelText: 'Establishment ID',
                  ),
                ),
                TextField(
                  controller: categoryController,
                  decoration: const InputDecoration(labelText: 'Category ID'),
                ),
                TextField(
                  controller: totalController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Total turnos'),
                ),
                TextField(
                  controller: priorityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Turnos prioritarios',
                  ),
                ),
                DropdownButtonFormField<String>(
                  initialValue: periodo,
                  items: const [
                    DropdownMenuItem(value: 'diario', child: Text('Diario')),
                    DropdownMenuItem(value: 'semanal', child: Text('Semanal')),
                    DropdownMenuItem(value: 'mensual', child: Text('Mensual')),
                  ],
                  onChanged: (v) {
                    if (v != null) periodo = v;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Crear'),
            ),
          ],
        );
      },
    );

    if (ok != true || !context.mounted) return;

    final total = int.tryParse(totalController.text.trim()) ?? 0;
    final prioritarios = int.tryParse(priorityController.text.trim()) ?? 0;

    final model = AfluenciaStatModel(
      id: '',
      establishmentId: establishmentController.text.trim(),
      categoryId: categoryController.text.trim(),
      totalTurnos: total,
      turnosPrioritarios: prioritarios,
      fechaHora: DateTime.now(),
      periodo: periodo,
    );

    final error = await context.read<AfluenciaStatsCubit>().create(model);
    if (!context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(error ?? 'Estadistica creada')));
  }
}
