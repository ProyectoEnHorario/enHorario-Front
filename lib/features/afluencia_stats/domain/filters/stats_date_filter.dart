enum StatsDatePreset {
  today,
  lastWeek,
  lastMonth,
  custom,
}

class StatsDateFilter {
  const StatsDateFilter({
    required this.preset,
    required this.from,
    required this.to,
  });

  final StatsDatePreset preset;
  final DateTime from;
  final DateTime to;

  bool get isValid => !from.isAfter(to);

  StatsDateFilter copyWith({
    StatsDatePreset? preset,
    DateTime? from,
    DateTime? to,
  }) {
    return StatsDateFilter(
      preset: preset ?? this.preset,
      from: from ?? this.from,
      to: to ?? this.to,
    );
  }

  static StatsDateFilter initial() => fromPreset(StatsDatePreset.lastWeek);

  static StatsDateFilter fromPreset(StatsDatePreset preset, {DateTime? now}) {
    final current = now ?? DateTime.now();
    final dayStart = DateTime(current.year, current.month, current.day);

    switch (preset) {
      case StatsDatePreset.today:
        return StatsDateFilter(
          preset: preset,
          from: dayStart,
          to: current,
        );
      case StatsDatePreset.lastWeek:
        return StatsDateFilter(
          preset: preset,
          from: dayStart.subtract(const Duration(days: 6)),
          to: current,
        );
      case StatsDatePreset.lastMonth:
        return StatsDateFilter(
          preset: preset,
          from: dayStart.subtract(const Duration(days: 29)),
          to: current,
        );
      case StatsDatePreset.custom:
        return StatsDateFilter(
          preset: preset,
          from: dayStart.subtract(const Duration(days: 6)),
          to: current,
        );
    }
  }
}
