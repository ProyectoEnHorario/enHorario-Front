import 'package:enhorario/core/utils/string_normalizer.dart';
import 'package:enhorario/features/establishments/data/models/railway_establishment_view.dart';

class EstablishmentCategoryOption {
  const EstablishmentCategoryOption({
    required this.key,
    required this.label,
    required this.count,
  });

  final String key;
  final String label;
  final int count;
}

class EstablishmentFilterLogic {
  static String categoryKey(String? categoryName) {
    final normalized = StringNormalizer.normalize(categoryName ?? '');
    return normalized;
  }

  static List<EstablishmentCategoryOption> buildCategoryOptions(
    List<RailwayEstablishmentView> items,
  ) {
    final counts = <String, int>{};
    final labels = <String, String>{};

    for (final item in items) {
      final label = (item.categoryName ?? '').trim();
      if (label.isEmpty) continue;

      final key = categoryKey(label);
      if (key.isEmpty) continue;

      counts[key] = (counts[key] ?? 0) + 1;
      labels.putIfAbsent(key, () => label);
    }

    final options = counts.entries.map((entry) {
      return EstablishmentCategoryOption(
        key: entry.key,
        label: labels[entry.key] ?? entry.key,
        count: entry.value,
      );
    }).toList();

    options.sort((a, b) => a.label.toLowerCase().compareTo(b.label.toLowerCase()));
    return options;
  }

  static List<RailwayEstablishmentView> applyFilters(
    List<RailwayEstablishmentView> items, {
    required String query,
    required Set<String> selectedCategoryKeys,
  }) {
    final normalizedQuery = StringNormalizer.normalize(query);

    return items.where((item) {
      final byCategory = selectedCategoryKeys.isEmpty
          ? true
          : selectedCategoryKeys.contains(categoryKey(item.categoryName));

      if (!byCategory) return false;

      if (normalizedQuery.isEmpty) return true;

      final byName = StringNormalizer.normalize(item.name).contains(normalizedQuery);
      final byCategoryName =
          StringNormalizer.normalize(item.categoryName ?? '').contains(normalizedQuery);
      final byCity = StringNormalizer.normalize(item.city).contains(normalizedQuery);

      return byName || byCategoryName || byCity;
    }).toList();
  }
}
