import 'package:enhorario/features/afluencia_stats/data/models/afluencia_dashboard_model.dart';
import 'package:flutter/material.dart';

class StatsBarChartCard extends StatelessWidget {
  const StatsBarChartCard({
    super.key,
    required this.title,
    required this.items,
    required this.emptyLabel,
  });

  final String title;
  final List<DashboardPoint> items;
  final String emptyLabel;

  @override
  Widget build(BuildContext context) {
    final maxValue = items.isEmpty
        ? 1
        : items.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (items.isEmpty)
              Text(emptyLabel)
            else
              Column(
                children: items.map((item) {
                  final ratio = item.value / maxValue;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Row(
                      children: [
                        SizedBox(
                          width: 120,
                          child: Text(
                            item.label,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(6),
                            child: LinearProgressIndicator(
                              value: ratio,
                              minHeight: 12,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(item.value.toString()),
                      ],
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
