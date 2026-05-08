import 'package:enhorario/core/utils/date_formatter.dart';
import 'package:enhorario/features/home/domain/entities/wait_point.dart';
import 'package:flutter/material.dart';

class WaitPointTile extends StatelessWidget {
  const WaitPointTile({
    super.key,
    required this.point,
  });

  final WaitPoint point;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final updatedAgo = DateTime.now().difference(point.updatedAt).inMinutes;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: scheme.tertiary.withOpacity(0.12),
        child: Text(
          point.category.substring(0, 1).toUpperCase(),
          style: TextStyle(color: scheme.tertiary, fontWeight: FontWeight.w700),
        ),
      ),
      title: Text(
        point.name,
        style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
      ),
      subtitle: Text('Actualizado hace ${formatMinutes(updatedAgo)}'),
      trailing: Chip(
        backgroundColor: scheme.primary.withOpacity(0.08),
        label: Text(
          '${point.estimatedMinutes} min',
          style: TextStyle(color: scheme.primary, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
