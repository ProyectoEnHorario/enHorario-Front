import 'dart:async';
import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:flutter/foundation.dart';

class AfluenciaMonitorService {
  static final AfluenciaMonitorService _instance = AfluenciaMonitorService._internal();

  factory AfluenciaMonitorService() {
    return _instance;
  }

  AfluenciaMonitorService._internal() {
    _queryService = RailwayEstablishmentQueryService(ApiClient());
  }

  late final RailwayEstablishmentQueryService _queryService;
  Timer? _timer;

  /// Inicia el monitoreo periódico de afluencia.
  void startMonitoring({Duration interval = const Duration(minutes: 5)}) {
    if (_timer != null) return;

    if (kDebugMode) {
      print('AfluenciaMonitorService: Iniciando monitoreo cada ${interval.inMinutes} minutos.');
    }

    _timer = Timer.periodic(interval, (_) => _checkAfluencia());
    
    // Ejecutar una primera vez de inmediato
    _checkAfluencia();
  }

  /// Detiene el monitoreo.
  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
    if (kDebugMode) {
      print('AfluenciaMonitorService: Monitoreo detenido.');
    }
  }

  Future<void> _checkAfluencia() async {
    if (kDebugMode) {
      print('AfluenciaMonitorService: Consultando datos de afluencia...');
    }

    final result = await _queryService.fetchEstablishments();

    result.fold(
      (failure) {
        if (kDebugMode) {
          print('AfluenciaMonitorService Error: ${failure.message}');
        }
      },
      (establishments) {
        if (kDebugMode) {
          print('AfluenciaMonitorService: ${establishments.length} establecimientos obtenidos.');
        }
        
        // ENH-150: Aquí implementaremos la lógica para detectar baja afluencia
      },
    );
  }
}
