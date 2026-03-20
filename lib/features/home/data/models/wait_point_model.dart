import 'package:enhorario/features/home/domain/entities/wait_point.dart';

class WaitPointModel extends WaitPoint {
  const WaitPointModel({
    required super.name,
    required super.category,
    required super.estimatedMinutes,
    required super.updatedAt,
  });

  factory WaitPointModel.fromMap(Map<String, dynamic> map) {
    return WaitPointModel(
      name: map['name'] as String,
      category: map['category'] as String,
      estimatedMinutes: map['estimatedMinutes'] as int,
      updatedAt: DateTime.parse(map['updatedAt'] as String),
    );
  }
}
