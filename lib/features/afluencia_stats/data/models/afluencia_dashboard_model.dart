class DashboardPoint {
  const DashboardPoint({required this.label, required this.value});

  final String label;
  final int value;
}

class DashboardSeriesPoint {
  const DashboardSeriesPoint({required this.date, required this.value});

  final DateTime date;
  final int value;
}

class AfluenciaDashboardModel {
  const AfluenciaDashboardModel({
    required this.totalVisits,
    required this.priorityVisits,
    required this.peakHourLabel,
    required this.mostConsultedEstablishments,
    required this.mostPopularCategories,
    required this.visitsTimeline,
    this.isFallbackData = false,
  });

  final int totalVisits;
  final int priorityVisits;
  final String peakHourLabel;
  final List<DashboardPoint> mostConsultedEstablishments;
  final List<DashboardPoint> mostPopularCategories;
  final List<DashboardSeriesPoint> visitsTimeline;
  final bool isFallbackData;

  int get regularVisits {
    final value = totalVisits - priorityVisits;
    return value < 0 ? 0 : value;
  }

  bool get hasData {
    return totalVisits > 0 ||
        priorityVisits > 0 ||
        mostConsultedEstablishments.isNotEmpty ||
        mostPopularCategories.isNotEmpty ||
        visitsTimeline.isNotEmpty;
  }

  factory AfluenciaDashboardModel.empty() {
    return const AfluenciaDashboardModel(
      totalVisits: 0,
      priorityVisits: 0,
      peakHourLabel: 'Sin datos',
      mostConsultedEstablishments: <DashboardPoint>[],
      mostPopularCategories: <DashboardPoint>[],
      visitsTimeline: <DashboardSeriesPoint>[],
      isFallbackData: false,
    );
  }
}
