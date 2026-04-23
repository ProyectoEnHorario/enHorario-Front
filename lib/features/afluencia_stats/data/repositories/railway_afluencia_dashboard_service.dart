import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/core/errors/api_exception.dart';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/afluencia_stats/data/models/afluencia_dashboard_model.dart';
import 'package:enhorario/features/afluencia_stats/domain/filters/stats_date_filter.dart';

class RailwayAfluenciaDashboardService {
  RailwayAfluenciaDashboardService(this._apiClient);

  final ApiClient _apiClient;

  Future<Result<AfluenciaDashboardModel>> fetchDashboard({
    required StatsDateFilter filter,
    required String token,
  }) async {
    try {
      final response = await _apiClient.get<dynamic>(
        '/admin/stats/overview',
        token: token,
        queryParameters: {
          'from': filter.from.toIso8601String(),
          'to': filter.to.toIso8601String(),
        },
      );

      if (response is! Map<String, dynamic>) {
        return const Left<Failure, AfluenciaDashboardModel>(
          Failure('Respuesta invalida del servidor para estadisticas.'),
        );
      }

      return Right<Failure, AfluenciaDashboardModel>(_fromMap(response));
    } on ApiException catch (e) {
      if (e.statusCode == 401 || e.statusCode == 403) {
        return const Left<Failure, AfluenciaDashboardModel>(
          Failure('Acceso denegado. Solo administradores pueden ver estadisticas.'),
        );
      }
      if ((e.statusCode ?? 0) >= 500) {
        return const Left<Failure, AfluenciaDashboardModel>(
          Failure('El servidor no esta disponible en este momento.'),
        );
      }
      return Left<Failure, AfluenciaDashboardModel>(
        Failure(e.message.isEmpty ? 'No fue posible obtener estadisticas.' : e.message),
      );
    } catch (_) {
      return const Left<Failure, AfluenciaDashboardModel>(
        Failure('Error inesperado al consultar estadisticas.'),
      );
    }
  }

  AfluenciaDashboardModel _fromMap(Map<String, dynamic> map) {
    final totalVisits = _toInt(map['totalVisits']);
    final priorityVisits = _toInt(map['priorityVisits']);

    final peakHourLabel = map['peakHourLabel']?.toString().trim();

    return AfluenciaDashboardModel(
      totalVisits: totalVisits,
      priorityVisits: priorityVisits,
      peakHourLabel: (peakHourLabel == null || peakHourLabel.isEmpty)
          ? 'Sin datos'
          : peakHourLabel,
      mostConsultedEstablishments: _parsePoints(map['mostConsultedEstablishments']),
      mostPopularCategories: _parsePoints(map['mostPopularCategories']),
      visitsTimeline: _parseSeries(map['visitsTimeline']),
      isFallbackData: false,
    );
  }

  List<DashboardPoint> _parsePoints(dynamic source) {
    if (source is! List) return const <DashboardPoint>[];

    return source.whereType<Map<String, dynamic>>().map((item) {
      final label = item['label']?.toString() ?? 'Sin nombre';
      final value = _toInt(item['value']);
      return DashboardPoint(label: label, value: value);
    }).where((item) => item.value >= 0).toList();
  }

  List<DashboardSeriesPoint> _parseSeries(dynamic source) {
    if (source is! List) return const <DashboardSeriesPoint>[];

    return source.whereType<Map<String, dynamic>>().map((item) {
      final rawDate = item['date'];
      DateTime parsedDate;
      if (rawDate is String) {
        parsedDate = DateTime.tryParse(rawDate) ?? DateTime.now();
      } else {
        parsedDate = DateTime.now();
      }
      final value = _toInt(item['value']);
      return DashboardSeriesPoint(date: parsedDate, value: value);
    }).where((item) => item.value >= 0).toList();
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.round();
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }
}
