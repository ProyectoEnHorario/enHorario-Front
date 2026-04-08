import 'package:flutter/material.dart';

class IndicadorAfluencia extends StatelessWidget {
  final double? valor; 
  final bool abierto;

  const IndicadorAfluencia({
    super.key,
    required this.valor,
    this.abierto = true,
  });

  Color get _colorBase {
    if (!abierto || valor == null) return Colors.grey.shade400;
    if (valor! <= 0.4) return Colors.green.shade500;
    if (valor! <= 0.75) return Colors.orange.shade500;
    return Colors.red.shade500;
  }

  List<Color> get _gradiente {
    if (!abierto || valor == null) return [Colors.grey.shade300, Colors.grey.shade400];
    if (valor! <= 0.4) return [Colors.green.shade400, Colors.green.shade600];
    if (valor! <= 0.75) return [Colors.orange.shade400, Colors.orange.shade600];
    return [Colors.red.shade400, Colors.red.shade700];
  }

  String get _etiqueta {
    if (!abierto) return 'Local cerrado';
    if (valor == null) return 'Sin datos';
    if (valor! <= 0.4) return 'Baja';
    if (valor! <= 0.75) return 'Media';
    return 'Alta';
  }

  IconData get _icono {
    if (!abierto) return Icons.lock_outline;
    if (valor == null) return Icons.help_outline;
    if (valor! <= 0.4) return Icons.check_circle_outline;
    if (valor! <= 0.75) return Icons.warning_amber_rounded;
    return Icons.error_outline;
  }

  @override
  Widget build(BuildContext context) {
    final double progreso = (abierto && valor != null) ? valor! : 0.0;
    final String textoPorcentaje = (abierto && valor != null) 
        ? '${(progreso * 100).toInt()}%' 
        : '';
    final Color color = _colorBase;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Icon(_icono, size: 16, color: color),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      (abierto && valor != null) ? 'Afluencia: $_etiqueta' : _etiqueta,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: color,
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
            if (textoPorcentaje.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(left: 8.0),
                child: Text(
                  textoPorcentaje,
                  style: TextStyle(
                    color: color, 
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          height: 10,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
            border: Border.all(color: Colors.grey.shade300, width: 0.5),
          ),
          alignment: Alignment.centerLeft,
          child: TweenAnimationBuilder<double>(
            tween: Tween<double>(begin: 0, end: progreso),
            duration: const Duration(milliseconds: 1000),
            curve: Curves.easeOutCubic,
            builder: (context, animValue, child) {
              if (animValue <= 0) return const SizedBox.shrink();
              return FractionallySizedBox(
                widthFactor: animValue,
                alignment: Alignment.centerLeft,
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    gradient: LinearGradient(
                      colors: _gradiente,
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: color.withValues(alpha: 0.4),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}