import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/afluencia_stats/data/models/afluencia_dashboard_model.dart';
import 'package:enhorario/features/afluencia_stats/domain/filters/stats_date_filter.dart';

abstract class AfluenciaDashboardRepository {
  Future<Result<AfluenciaDashboardModel>> fetchDashboard({
    required StatsDateFilter filter,
    required String token,
  });
}
