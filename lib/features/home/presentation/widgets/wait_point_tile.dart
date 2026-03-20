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
      contentPadding: const EdgeInsets.symmetric(horizontal: 12),
      leading: CircleAvatar(
        backgroundColor: scheme.primaryContainer,
        foregroundColor: scheme.onPrimaryContainer,
        child: Text(point.category.substring(0, 1)),
      ),
      title: Text(
        point.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text('Actualizado hace ${formatMinutes(updatedAgo)}'),
      trailing: Chip(
        label: Text('${point.estimatedMinutes} min'),
      ),
    );
  }
}
