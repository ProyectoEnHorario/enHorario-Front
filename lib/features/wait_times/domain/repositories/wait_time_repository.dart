import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/wait_times/data/models/wait_time_model.dart';

abstract class WaitTimeRepository {
  Stream<WaitTimeModel?> watchByEstablishment(String establishmentId);

  Future<Result<void>> upsert(WaitTimeModel model);
}
