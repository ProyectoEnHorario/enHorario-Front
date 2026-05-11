import 'package:flutter/material.dart';

class VisualizacionAfluenciaFranjasWidget extends StatefulWidget {
  const VisualizacionAfluenciaFranjasWidget({
    super.key,
    this.referenceDate,
    this.debugForceError = false,
  });

  final DateTime? referenceDate;
  final bool debugForceError;

  @override
  State<VisualizacionAfluenciaFranjasWidget> createState() =>
      _VisualizacionAfluenciaFranjasWidgetState();
}

class _VisualizacionAfluenciaFranjasWidgetState
    extends State<VisualizacionAfluenciaFranjasWidget> {
  late Future<List<_PrediccionFranja>> _prediccionesFuture;

  static const Map<int, List<_PrediccionFranja>> _prediccionesMock = {
    DateTime.monday: [
      _PrediccionFranja('Mañana', '6:00 - 12:00', 0.25, Icons.wb_sunny_outlined),
      _PrediccionFranja('Tarde', '12:00 - 18:00', 0.55, Icons.light_mode_outlined),
      _PrediccionFranja('Noche', '18:00 - 22:00', 0.8, Icons.nightlight_round),
    ],
    DateTime.tuesday: [
      _PrediccionFranja('Mañana', '6:00 - 12:00', 0.3, Icons.wb_sunny_outlined),
      _PrediccionFranja('Tarde', '12:00 - 18:00', 0.65, Icons.light_mode_outlined),
      _PrediccionFranja('Noche', '18:00 - 22:00', null, Icons.nightlight_round),
    ],
    DateTime.wednesday: [
      _PrediccionFranja('Mañana', '6:00 - 12:00', 0.2, Icons.wb_sunny_outlined),
      _PrediccionFranja('Tarde', '12:00 - 18:00', 0.4, Icons.light_mode_outlined),
      _PrediccionFranja('Noche', '18:00 - 22:00', 0.7, Icons.nightlight_round),
    ],
    DateTime.thursday: [
      _PrediccionFranja('Mañana', '6:00 - 12:00', null, Icons.wb_sunny_outlined),
      _PrediccionFranja('Tarde', '12:00 - 18:00', 0.5, Icons.light_mode_outlined),
      _PrediccionFranja('Noche', '18:00 - 22:00', 0.85, Icons.nightlight_round),
    ],
    DateTime.friday: [
      _PrediccionFranja('Mañana', '6:00 - 12:00', 0.35, Icons.wb_sunny_outlined),
      _PrediccionFranja('Tarde', '12:00 - 18:00', 0.7, Icons.light_mode_outlined),
      _PrediccionFranja('Noche', '18:00 - 22:00', 0.9, Icons.nightlight_round),
    ],
    DateTime.saturday: [
      _PrediccionFranja('Mañana', '6:00 - 12:00', 0.4, Icons.wb_sunny_outlined),
      _PrediccionFranja('Tarde', '12:00 - 18:00', 0.75, Icons.light_mode_outlined),
      _PrediccionFranja('Noche', '18:00 - 22:00', null, Icons.nightlight_round),
    ],
    DateTime.sunday: [
      _PrediccionFranja('Mañana', '6:00 - 12:00', 0.15, Icons.wb_sunny_outlined),
      _PrediccionFranja('Tarde', '12:00 - 18:00', 0.45, Icons.light_mode_outlined),
      _PrediccionFranja('Noche', '18:00 - 22:00', 0.6, Icons.nightlight_round),
    ],
  };

  @override
  void initState() {
    super.initState();
    _prediccionesFuture = _loadPredicciones();
  }

  @override
  void didUpdateWidget(covariant VisualizacionAfluenciaFranjasWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.referenceDate != widget.referenceDate ||
        oldWidget.debugForceError != widget.debugForceError) {
      _prediccionesFuture = _loadPredicciones();
    }
  }

  Future<List<_PrediccionFranja>> _loadPredicciones() async {
    await Future<void>.delayed(const Duration(milliseconds: 350));
    if (widget.debugForceError) {
      throw Exception('No se pudieron cargar las predicciones');
    }
    final day = widget.referenceDate?.weekday ?? DateTime.now().weekday;
    return _prediccionesMock[day] ?? const [];
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return FutureBuilder<List<_PrediccionFranja>>(
      future: _prediccionesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _PredictionLoadingState(colorScheme: colorScheme, textTheme: textTheme);
        }

        if (snapshot.hasError) {
          return _PredictionErrorState(
            message: 'No se pudieron cargar las predicciones de afluencia.',
            colorScheme: colorScheme,
            textTheme: textTheme,
          );
        }

        final predictions = snapshot.data ?? const <_PrediccionFranja>[];

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Predicción por franjas',
              style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              'Estimación basada en datos históricos del día actual de la semana.',
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                for (var index = 0; index < predictions.length; index++)
                  Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: index == predictions.length - 1 ? 0 : 8,
                      ),
                      child: _PredictionBandCard(
                        franja: predictions[index],
                        color: colorScheme.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _PredictionLoadingState extends StatelessWidget {
  const _PredictionLoadingState({required this.colorScheme, required this.textTheme});

  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Predicción por franjas',
          style: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 8),
        Text(
          'Cargando predicciones...',
          style: textTheme.bodySmall?.copyWith(
            color: colorScheme.onSurface.withOpacity(0.6),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Padding(
                padding: EdgeInsets.only(right: index == 2 ? 0 : 8),
                child: Container(
                  height: 132,
                  decoration: BoxDecoration(
                    color: colorScheme.surfaceContainerHighest.withOpacity(0.35),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _PredictionErrorState extends StatelessWidget {
  const _PredictionErrorState({
    required this.message,
    required this.colorScheme,
    required this.textTheme,
  });

  final String message;
  final ColorScheme colorScheme;
  final TextTheme textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withOpacity(0.35),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.error.withOpacity(0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline, color: colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: textTheme.bodyMedium?.copyWith(
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictionBandCard extends StatelessWidget {
  const _PredictionBandCard({required this.franja, required this.color});

  final _PrediccionFranja franja;
  final Color color;

  String get _label {
    if (franja.valor == null) return 'Sin datos disponibles';
    if (franja.valor! <= 0.4) return 'Bajo';
    if (franja.valor! <= 0.75) return 'Medio';
    return 'Alto';
  }

  Color get _levelColor {
    if (franja.valor == null) return Colors.grey;
    if (franja.valor! <= 0.4) return Colors.green;
    if (franja.valor! <= 0.75) return Colors.orange;
    return Colors.red;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(franja.icono, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            franja.titulo,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
          ),
          const SizedBox(height: 4),
          Text(
            franja.rango,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: LinearProgressIndicator(
              value: franja.valor,
              minHeight: 8,
              backgroundColor: Colors.grey.shade200,
              valueColor: AlwaysStoppedAnimation<Color>(_levelColor),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _levelColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(color: _levelColor.withOpacity(0.28)),
            ),
            child: Text(
              _label,
              style: TextStyle(
                fontSize: 11,
                color: _levelColor,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          if (franja.valor != null) ...[
            const SizedBox(height: 6),
            Text(
              '${(franja.valor! * 100).toInt()}%',
              style: TextStyle(fontSize: 11, color: Colors.grey.shade700),
            ),
          ],
        ],
      ),
    );
  }
}

class _PrediccionFranja {
  const _PrediccionFranja(this.titulo, this.rango, this.valor, this.icono);

  final String titulo;
  final String rango;
  final double? valor;
  final IconData icono;
}
