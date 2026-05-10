import 'package:flutter/material.dart';
import 'package:enhorario/features/turns/data/models/turn_model.dart';

class EstadoTurnoActivoWidget extends StatelessWidget {
  final TurnModel turn;
  final VoidCallback onCancel;
  final bool isCancelling;

  const EstadoTurnoActivoWidget({
    super.key,
    required this.turn,
    required this.onCancel,
    this.isCancelling = false,
  });

  @override
  Widget build(BuildContext context) {
    final bool isPriority = turn.tipo == 'prioritario';

    return Card(
      elevation: 4,
      shadowColor: (isPriority ? Colors.orange : Colors.blue).withValues(alpha: 0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: (isPriority ? Colors.orange : Colors.blue).withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Tu Turno Activo',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                    Text(
                      turn.codigo,
                      style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isPriority ? Colors.orange : Colors.blue,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: (isPriority ? Colors.orange : Colors.blue).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    isPriority ? '★ PRIORITARIO' : 'REGULAR',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: isPriority ? Colors.orange : Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
            const Divider(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem(
                  Icons.format_list_numbered,
                  'Posición',
                  '#${turn.posicion}',
                  Colors.indigo,
                ),
                _buildInfoItem(
                  Icons.timer_outlined,
                  'Espera Est.',
                  '~15 min', // Esto se calculará en la siguiente fase
                  Colors.teal,
                ),
              ],
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: isCancelling ? null : () => _confirmarCancelacion(context),
              icon: isCancelling 
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.cancel_outlined, color: Colors.red),
              label: const Text('Cancelar mi turno', style: TextStyle(color: Colors.red)),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(IconData icon, String label, String value, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  void _confirmarCancelacion(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Cancelar turno?'),
        content: const Text('Si cancelas, perderás tu posición actual en la fila.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Volver'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              onCancel();
            },
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
  }
}
