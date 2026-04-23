import 'dart:math';

import 'package:enhorario/features/afluencia_stats/data/models/afluencia_dashboard_model.dart';
import 'package:enhorario/features/afluencia_stats/domain/filters/stats_date_filter.dart';

class LocalAfluenciaDashboardService {
  AfluenciaDashboardModel buildDashboard(StatsDateFilter filter) {
    final seed = filter.from.millisecondsSinceEpoch ^ filter.to.millisecondsSinceEpoch;
    final random = Random(seed);

    final days = filter.to.difference(filter.from).inDays + 1;
    final timeline = <DashboardSeriesPoint>[];

    var totalVisits = 0;
    for (var i = 0; i < days; i++) {
      final date = DateTime(filter.from.year, filter.from.month, filter.from.day + i);
      final value = 20 + random.nextInt(130);
      totalVisits += value;
      timeline.add(DashboardSeriesPoint(date: date, value: value));
    }

    final priorityVisits = (totalVisits * 0.22).round();

    final establishments = <DashboardPoint>[
      DashboardPoint(label: 'Banco Centro', value: 140 + random.nextInt(60)),
      DashboardPoint(label: 'Supermercado Norte', value: 120 + random.nextInt(50)),
      DashboardPoint(label: 'Clinica San Jose', value: 100 + random.nextInt(50)),
      DashboardPoint(label: 'Restaurante Plaza', value: 80 + random.nextInt(45)),
    ];

    final categories = <DashboardPoint>[
      DashboardPoint(label: 'Bancos', value: 160 + random.nextInt(45)),
      DashboardPoint(label: 'Comercios', value: 140 + random.nextInt(45)),
      DashboardPoint(label: 'Restaurantes', value: 120 + random.nextInt(40)),
      DashboardPoint(label: 'Salud', value: 90 + random.nextInt(35)),
    ];

    final peakHour = 10 + random.nextInt(7);

    return AfluenciaDashboardModel(
      totalVisits: totalVisits,
      priorityVisits: priorityVisits,
      peakHourLabel: '${peakHour.toString().padLeft(2, '0')}:00 - ${(peakHour + 1).toString().padLeft(2, '0')}:00',
      mostConsultedEstablishments: establishments,
      mostPopularCategories: categories,
      visitsTimeline: timeline,
      isFallbackData: true,
    );
  }
}
