class DateMapper {
  const DateMapper._();

  static DateTime? toDateTime(dynamic value) {
    if (value == null) return null;

    if (value is DateTime) return value;

    if (value is num) {
      final raw = value.toInt();
      final milliseconds = raw.abs() < 100000000000 ? raw * 1000 : raw;
      return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true)
          .toLocal();
    }

    if (value is String) {
      final trimmed = value.trim();
      if (trimmed.isEmpty) return null;

      final numeric = int.tryParse(trimmed);
      if (numeric != null) {
        final milliseconds =
            numeric.abs() < 100000000000 ? numeric * 1000 : numeric;
        return DateTime.fromMillisecondsSinceEpoch(milliseconds, isUtc: true)
            .toLocal();
      }

      return DateTime.tryParse(trimmed)?.toLocal();
    }

    return null;
  }

  static String? toIsoString(DateTime? value) {
    return value?.toUtc().toIso8601String();
  }
}
