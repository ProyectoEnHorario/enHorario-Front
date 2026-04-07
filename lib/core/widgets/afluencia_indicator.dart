import 'package:flutter/material.dart';

class AfluenciaIndicator extends StatelessWidget {
  final double value; // valor entre 0.0 y 1.0

  const AfluenciaIndicator({super.key, required this.value});

  Color get _color {
    if (value <= 0.4) return Colors.green;
    if (value <= 0.75) return Colors.orange;
    return Colors.red;
  }

  String get _label {
    if (value <= 0.4) return 'Baja';
    if (value <= 0.75) return 'Media';
    return 'Alta';
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Afluencia: $_label',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: _color,
                fontSize: 14,
              ),
            ),
            Text(
              '${(value * 100).toInt()}%',
              style: TextStyle(color: _color, fontSize: 13),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: value,
            minHeight: 10,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(_color),
          ),
        ),
      ],
    );
  }
}