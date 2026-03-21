import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/afluencia_stats/data/models/afluencia_stat_model.dart';

abstract class AfluenciaStatsRepository {
  Stream<List<AfluenciaStatModel>> watchAll();

  Future<Result<void>> create(AfluenciaStatModel model);
}
