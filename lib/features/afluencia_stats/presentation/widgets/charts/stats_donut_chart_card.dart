import 'dart:math' as math;

import 'package:flutter/material.dart';

class StatsDonutChartCard extends StatelessWidget {
  const StatsDonutChartCard({
    super.key,
    required this.title,
    required this.primaryLabel,
    required this.primaryValue,
    required this.secondaryLabel,
    required this.secondaryValue,
  });

  final String title;
  final String primaryLabel;
  final int primaryValue;
  final String secondaryLabel;
  final int secondaryValue;

  @override
  Widget build(BuildContext context) {
    final total = primaryValue + secondaryValue;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            Row(
              children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: CustomPaint(
                    painter: _DonutPainter(
                      primary: primaryValue,
                      secondary: secondaryValue,
                      primaryColor: Theme.of(context).colorScheme.primary,
                      secondaryColor: Theme.of(context).colorScheme.secondary,
                    ),
                    child: Center(
                      child: Text(
                        total.toString(),
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _LegendItem(
                        color: Theme.of(context).colorScheme.primary,
                        label: '$primaryLabel: $primaryValue',
                      ),
                      const SizedBox(height: 8),
                      _LegendItem(
                        color: Theme.of(context).colorScheme.secondary,
                        label: '$secondaryLabel: $secondaryValue',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _LegendItem extends StatelessWidget {
  const _LegendItem({required this.color, required this.label});

  final Color color;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 8),
        Expanded(child: Text(label)),
      ],
    );
  }
}

class _DonutPainter extends CustomPainter {
  _DonutPainter({
    required this.primary,
    required this.secondary,
    required this.primaryColor,
    required this.secondaryColor,
  });

  final int primary;
  final int secondary;
  final Color primaryColor;
  final Color secondaryColor;

  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.16;
    final rect = Rect.fromLTWH(stroke, stroke, size.width - stroke * 2, size.height - stroke * 2);
    final total = primary + secondary;

    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..color = const Color(0x14000000);

    canvas.drawArc(rect, -math.pi / 2, math.pi * 2, false, basePaint);

    if (total <= 0) return;

    final primarySweep = (primary / total) * math.pi * 2;

    final primaryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = primaryColor;

    final secondaryPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round
      ..color = secondaryColor;

    canvas.drawArc(rect, -math.pi / 2, primarySweep, false, primaryPaint);
    canvas.drawArc(rect, -math.pi / 2 + primarySweep, math.pi * 2 - primarySweep, false, secondaryPaint);
  }

  @override
  bool shouldRepaint(covariant _DonutPainter oldDelegate) {
    return oldDelegate.primary != primary ||
        oldDelegate.secondary != secondary ||
        oldDelegate.primaryColor != primaryColor ||
        oldDelegate.secondaryColor != secondaryColor;
  }
}
