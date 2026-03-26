class DateMapper {
  const DateMapper._();

  static DateTime? toDateTime(dynamic value) {
    if (value == null) return null;
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  static String? toIsoString(DateTime? value) {
    if (value == null) return null;
    return value.toIso8601String();
  }
}
