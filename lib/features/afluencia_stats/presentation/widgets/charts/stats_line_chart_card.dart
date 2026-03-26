import 'dart:math' as math;

import 'package:enhorario/features/afluencia_stats/data/models/afluencia_dashboard_model.dart';
import 'package:flutter/material.dart';

class StatsLineChartCard extends StatelessWidget {
  const StatsLineChartCard({
    super.key,
    required this.title,
    required this.points,
    required this.emptyLabel,
  });

  final String title;
  final List<DashboardSeriesPoint> points;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (points.isEmpty)
              Text(emptyLabel)
            else ...[
              SizedBox(
                height: 170,
                child: CustomPaint(
                  painter: _LineChartPainter(
                    points.map((e) => e.value.toDouble()).toList(),
                    Theme.of(context).colorScheme.primary,
                  ),
                  child: const SizedBox.expand(),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(_formatDate(points.first.date), style: Theme.of(context).textTheme.bodySmall),
                  Text(_formatDate(points.last.date), style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    final d = value.day.toString().padLeft(2, '0');
    final m = value.month.toString().padLeft(2, '0');
    return '$d/$m';
  }
}

class _LineChartPainter extends CustomPainter {
  _LineChartPainter(this.values, this.color);

  final List<double> values;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (values.length < 2) return;

    final maxY = values.reduce(math.max);
    final minY = values.reduce(math.min);
    final yRange = (maxY - minY).abs() < 1 ? 1 : (maxY - minY);

    final gridPaint = Paint()
      ..color = const Color(0x22000000)
      ..strokeWidth = 1;

    for (var i = 0; i < 4; i++) {
      final y = size.height * (i / 3);
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = (i / (values.length - 1)) * size.width;
      final normalized = (values[i] - minY) / yRange;
      final y = size.height - (normalized * size.height);
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _LineChartPainter oldDelegate) {
    return oldDelegate.values != values || oldDelegate.color != color;
  }
}
