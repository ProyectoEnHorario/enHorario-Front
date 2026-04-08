import 'package:enhorario/core/widgets/indicador_afluencia.dart';
import 'package:enhorario/features/afluencia_stats/data/models/afluencia_stat_model.dart';
import 'package:enhorario/features/establishments/data/models/establishment_model.dart';
import 'package:flutter/material.dart';

class PantallaDetalleEstablecimiento extends StatelessWidget {
  const PantallaDetalleEstablecimiento({
    super.key,
    required this.item,
    this.afluenciaStat,
  });

  final EstablishmentModel item;
  final AfluenciaStatModel? afluenciaStat; // opcional, puede llegar null

  // Convierte totalTurnos a un valor entre 0.0 y 1.0
  // Usamos 50 como máximo razonable de turnos simultáneos
  static const int _maximosTurnos = 50;

  double? get _valorAfluencia {
    if (afluenciaStat == null) return null;
    final raw = afluenciaStat!.totalTurnos / _maximosTurnos;
    return raw.clamp(0.0, 1.0); // nunca pasa de 1.0
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: Text(item.nombre)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [

          // ── Sección: estado del establecimiento ──────────────────
          _SectionTitle(text: 'Estado'),
          const SizedBox(height: 8),
          Row(
            children: [
              _StatusChip(
                label: item.abierto ? 'Abierto' : 'Cerrado',
                color: item.abierto ? Colors.green : Colors.red,
              ),
              const SizedBox(width: 8),
              _StatusChip(
                label: item.activo ? 'Activo' : 'Inactivo',
                color: item.activo ? Colors.blue : Colors.grey,
              ),
            ],
          ),

          const SizedBox(height: 24),

          // ── Sección: afluencia actual ─────────────────────────────
          _SectionTitle(text: 'Afluencia actual'),
          const SizedBox(height: 12),

          // Aquí usas el widget que creaste
          IndicadorAfluencia(
            valor: _valorAfluencia,
            abierto: item.abierto,
          ),

          // Muestra los turnos reales si hay datos
          if (afluenciaStat != null) ...[
            const SizedBox(height: 6),
            Text(
              '${afluenciaStat!.totalTurnos} turnos activos '
                  '(${afluenciaStat!.turnosPrioritarios} prioritarios)',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade600,
              ),
            ),
          ] else ...[
            const SizedBox(height: 6),
            Text(
              'Sin datos de afluencia disponibles',
              style: textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade500,
              ),
            ),
          ],

          const SizedBox(height: 24),

          // ── Sección: información general ─────────────────────────
          _SectionTitle(text: 'Información'),
          const SizedBox(height: 8),
          _InfoRow(label: 'Dirección', value: item.direccion),
          if (item.descripcion != null)
            _InfoRow(label: 'Descripción', value: item.descripcion!),
          _InfoRow(label: 'Categoría', value: item.categoryId),
          _InfoRow(
            label: 'Creado',
            value: '${item.createdAt.day}/${item.createdAt.month}/${item.createdAt.year}',
          ),
        ],
      ),
    );
  }
}

// ── Widgets privados de apoyo ─────────────────────────────────────────

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 13,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }
}