import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/afluencia_stats/data/models/afluencia_dashboard_model.dart';
import 'package:enhorario/features/afluencia_stats/data/repositories/local_afluencia_dashboard_service.dart';
import 'package:enhorario/features/afluencia_stats/data/repositories/railway_afluencia_dashboard_service.dart';
import 'package:enhorario/features/afluencia_stats/domain/filters/stats_date_filter.dart';
import 'package:enhorario/features/afluencia_stats/domain/repositories/afluencia_dashboard_repository.dart';

class HybridAfluenciaDashboardRepository implements AfluenciaDashboardRepository {
  HybridAfluenciaDashboardRepository(this._remote, this._local);

  final RailwayAfluenciaDashboardService _remote;
  final LocalAfluenciaDashboardService _local;

  @override
  Future<Result<AfluenciaDashboardModel>> fetchDashboard({
    required StatsDateFilter filter,
    required String token,
  }) async {
    if (!filter.isValid) {
      return const Left<Failure, AfluenciaDashboardModel>(
        Failure('El rango de fechas es invalido.'),
      );
    }

    if (token.trim().isEmpty) {
      return Right<Failure, AfluenciaDashboardModel>(_local.buildDashboard(filter));
    }

    final remote = await _remote.fetchDashboard(filter: filter, token: token);
    return remote.fold(
      (failure) {
        // Solo caemos a datos locales cuando hay indisponibilidad del servicio,
        // nunca cuando hay error de permisos.
        if (failure.message.toLowerCase().contains('acceso denegado')) {
          return Left<Failure, AfluenciaDashboardModel>(failure);
        }
        return Right<Failure, AfluenciaDashboardModel>(_local.buildDashboard(filter));
      },
      (dashboard) => Right<Failure, AfluenciaDashboardModel>(dashboard),
    );
  }
}
