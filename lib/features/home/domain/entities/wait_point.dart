class WaitPoint {
  const WaitPoint({
    required this.name,
    required this.category,
    required this.estimatedMinutes,
    required this.updatedAt,
  });

  final String name;
  final String category;
  final int estimatedMinutes;
  final DateTime updatedAt;
}
