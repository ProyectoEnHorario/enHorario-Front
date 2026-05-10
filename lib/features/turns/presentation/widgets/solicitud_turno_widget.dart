import 'package:flutter/material.dart';

class SolicitudTurnoWidget extends StatefulWidget {
  final String establishmentId;
  final VoidCallback onTurnRequested;

  const SolicitudTurnoWidget({
    super.key,
    required this.establishmentId,
    required this.onTurnRequested,
  });

  @override
  State<SolicitudTurnoWidget> createState() => _SolicitudTurnoWidgetState();
}

class _SolicitudTurnoWidgetState extends State<SolicitudTurnoWidget> {
  bool _isPriority = false;
  String _priorityReason = 'adulto_mayor';

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: Theme.of(context).primaryColor.withValues(alpha: 0.2)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.confirmation_number_outlined, color: Theme.of(context).primaryColor),
                const SizedBox(width: 8),
                const Text(
                  'Solicitar Turno Virtual',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Evita filas físicas pidiendo tu turno desde aquí.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
            const SizedBox(height: 16),
            
            // Selector de Prioridad
            SwitchListTile(
              title: const Text('Turno con Prioridad'),
              subtitle: const Text('Adultos mayores, gestantes o discapacidad.'),
              value: _isPriority,
              onChanged: (value) => setState(() => _isPriority = value),
              activeColor: Colors.orange,
              contentPadding: EdgeInsets.zero,
            ),

            if (_isPriority) ...[
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _priorityReason,
                decoration: const InputDecoration(
                  labelText: 'Motivo de prioridad',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 'adulto_mayor', child: Text('Adulto Mayor (+65 años)')),
                  DropdownMenuItem(value: 'mujer_gestante', child: Text('Mujer Gestante')),
                  DropdownMenuItem(value: 'discapacidad', child: Text('Persona con Discapacidad')),
                ],
                onChanged: (value) => setState(() => _priorityReason = value!),
              ),
            ],

            const SizedBox(height: 20),
            
            FilledButton.icon(
              onPressed: () {
                context.read<TurnRequestCubit>().requestTurn(
                  establishmentId: widget.establishmentId,
                  isPriority: _isPriority,
                  priorityReason: _isPriority ? _priorityReason : null,
                );
              },
              icon: context.watch<TurnRequestCubit>().state is TurnRequestLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Icon(Icons.send_rounded),
              label: Text(_isPriority ? 'Solicitar Turno Prioritario' : 'Solicitar Turno Regular'),
              style: FilledButton.styleFrom(
                backgroundColor: _isPriority ? Colors.orange : null,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
