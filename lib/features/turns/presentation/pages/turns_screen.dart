import 'package:enhorario/features/turns/data/models/turn_model.dart';
import 'package:enhorario/features/turns/data/repositories/firestore_turn_repository.dart';
import 'package:enhorario/features/turns/presentation/bloc/turns_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class TurnsScreen extends StatefulWidget {
  const TurnsScreen({super.key});

  @override
  State<TurnsScreen> createState() => _TurnsScreenState();
}

class _TurnsScreenState extends State<TurnsScreen> {
  final _establishmentController = TextEditingController();

  @override
  void dispose() {
    _establishmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => TurnsCubit(FirestoreTurnRepository()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Turnos')),
        body: BlocBuilder<TurnsCubit, TurnsState>(
          builder: (context, state) {
            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: TextField(
                    controller: _establishmentController,
                    decoration: const InputDecoration(
                      labelText: 'Establishment ID',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (value) {
                      context.read<TurnsCubit>().listen(value.trim());
                    },
                  ),
                ),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        context.read<TurnsCubit>().listen(
                          _establishmentController.text.trim(),
                        );
                      },
                      child: const Text('Cargar turnos'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final error = await context
                            .read<TurnsCubit>()
                            .createTurn('regular');
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error ?? 'Turno regular creado'),
                          ),
                        );
                      },
                      child: const Text('Crear regular'),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final error = await context
                            .read<TurnsCubit>()
                            .createTurn('prioritario');
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(error ?? 'Turno prioritario creado'),
                          ),
                        );
                      },
                      child: const Text('Crear prioritario'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                if (state.isLoading)
                  const Expanded(
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (state.error != null)
                  Expanded(child: Center(child: Text(state.error!)))
                else if (state.items.isEmpty)
                  const Expanded(
                    child: Center(child: Text('No hay turnos para mostrar')),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      itemCount: state.items.length,
                      itemBuilder: (context, index) {
                        final turn = state.items[index];
                        return _TurnTile(turn: turn);
                      },
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _TurnTile extends StatelessWidget {
  const _TurnTile({required this.turn});

  final TurnModel turn;

  @override
  Widget build(BuildContext context) {
    final isPriority = turn.tipo == 'prioritario';
    return Card(
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isPriority ? Colors.orange : Colors.blue,
          child: Text(turn.posicion.toString()),
        ),
        title: Text('${turn.codigo} - ${turn.estado}'),
        subtitle: Text(isPriority ? 'Prioritario' : 'Regular'),
        trailing: Wrap(
          spacing: 4,
          children: [
            IconButton(
              icon: const Icon(Icons.play_arrow),
              onPressed: turn.estado == 'atendido' || turn.estado == 'cancelado'
                  ? null
                  : () async {
                      final error = await context
                          .read<TurnsCubit>()
                          .advanceTurn(turn);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error ?? 'Estado actualizado')),
                      );
                    },
            ),
            IconButton(
              icon: const Icon(Icons.cancel),
              onPressed: turn.estado == 'cancelado'
                  ? null
                  : () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Confirmar cancelacion'),
                          content: Text('Cancelar turno ${turn.codigo}?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('No'),
                            ),
                            ElevatedButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Si'),
                            ),
                          ],
                        ),
                      );
                      if (ok != true || !context.mounted) return;
                      final error = await context.read<TurnsCubit>().cancelTurn(
                        turn,
                      );
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error ?? 'Turno cancelado')),
                      );
                    },
            ),
          ],
        ),
      ),
    );
  }
}
