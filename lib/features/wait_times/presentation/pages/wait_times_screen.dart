import 'package:enhorario/features/wait_times/data/repositories/local_wait_time_repository.dart';
import 'package:enhorario/features/wait_times/presentation/bloc/wait_times_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class WaitTimesScreen extends StatefulWidget {
  const WaitTimesScreen({super.key});

  @override
  State<WaitTimesScreen> createState() => _WaitTimesScreenState();
}

class _WaitTimesScreenState extends State<WaitTimesScreen> {
  final _establishmentController = TextEditingController();
  final _minutesController = TextEditingController();

  @override
  void dispose() {
    _establishmentController.dispose();
    _minutesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => WaitTimesCubit(LocalWaitTimeRepository()),
      child: Scaffold(
        appBar: AppBar(title: const Text('Tiempo de espera')),
        body: BlocBuilder<WaitTimesCubit, WaitTimesState>(
          builder: (context, state) {
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  TextField(
                    controller: _establishmentController,
                    decoration: const InputDecoration(
                      labelText: 'Establishment ID',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      context.read<WaitTimesCubit>().listen(
                        _establishmentController.text.trim(),
                      );
                    },
                    child: const Text('Consultar en tiempo real'),
                  ),
                  const Divider(height: 24),
                  if (state.isLoading)
                    const CircularProgressIndicator()
                  else if (state.error != null)
                    Text(state.error!)
                  else if (state.item == null)
                    const Text(
                      'No hay tiempo registrado para este establecimiento',
                    )
                  else
                    Text('Tiempo actual: ${state.item!.minutos} minutos'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _minutesController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Nuevo tiempo (minutos)',
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () async {
                      final minutes = int.tryParse(
                        _minutesController.text.trim(),
                      );
                      if (minutes == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Ingresa un numero valido'),
                          ),
                        );
                        return;
                      }
                      final error = await context
                          .read<WaitTimesCubit>()
                          .saveMinutes(minutes);
                      if (!context.mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(error ?? 'Tiempo actualizado')),
                      );
                    },
                    child: const Text('Actualizar (solo admin)'),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
