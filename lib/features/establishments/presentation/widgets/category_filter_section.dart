import 'package:enhorario/features/establishments/domain/filters/establishment_filter_logic.dart';
import 'package:flutter/material.dart';

class CategoryFilterSection extends StatelessWidget {
  const CategoryFilterSection({
    super.key,
    required this.options,
    required this.selectedKeys,
    required this.onToggleCategory,
    required this.onClearAll,
  });

  final List<EstablishmentCategoryOption> options;
  final Set<String> selectedKeys;
  final ValueChanged<String> onToggleCategory;
  final VoidCallback onClearAll;

  @override
  Widget build(BuildContext context) {
    final hasActiveFilters = selectedKeys.isNotEmpty;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Categorías',
              style: Theme.of(context).textTheme.titleSmall,
            ),
            const Spacer(),
            if (hasActiveFilters)
              TextButton.icon(
                onPressed: onClearAll,
                icon: const Icon(Icons.filter_alt_off_outlined, size: 18),
                label: const Text('Limpiar filtros'),
              ),
          ],
        ),
        const SizedBox(height: 8),
        if (options.isEmpty)
          Text(
            'No hay categorías disponibles.',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: options.map((option) {
              final isSelected = selectedKeys.contains(option.key);
              return FilterChip(
                selected: isSelected,
                showCheckmark: true,
                label: Text('${option.label} (${option.count})'),
                onSelected: (_) => onToggleCategory(option.key),
              );
            }).toList(),
          ),
      ],
    );
  }
}
