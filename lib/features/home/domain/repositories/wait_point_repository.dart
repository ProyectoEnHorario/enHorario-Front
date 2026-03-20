import 'package:enhorario/features/home/domain/entities/wait_point.dart';

abstract class WaitPointRepository {
  Future<List<WaitPoint>> getTodayWaitPoints();
}
