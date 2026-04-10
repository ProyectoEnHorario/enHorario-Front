import 'dart:async';
import 'package:enhorario/core/api/api_client.dart';
import 'package:enhorario/core/config/app_config.dart';
import 'package:enhorario/core/services/notification_payload.dart';
import 'package:enhorario/core/services/notification_service.dart';
import 'package:enhorario/features/establishments/data/repositories/railway_establishment_query_service.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AfluenciaMonitorService {
  static final AfluenciaMonitorService _instance =
      AfluenciaMonitorService._internal();

  factory AfluenciaMonitorService() {
    return _instance;
  }

  AfluenciaMonitorService._internal() {
    _queryService = RailwayEstablishmentQueryService(ApiClient());
  }

  late final RailwayEstablishmentQueryService _queryService;
  Timer? _timer;

  /// Memoria temporal de las últimas notificaciones enviadas por establecimiento.
  final Map<String, DateTime> _lastNotificationTimes = {};

  /// Inicia el monitoreo periódico de afluencia.
  void startMonitoring({Duration interval = const Duration(minutes: 5)}) {
    if (_timer != null) return;

    if (kDebugMode) {
      print(
          'AfluenciaMonitorService: Iniciando monitoreo cada ${interval.inMinutes} minutos.');
    }

    _timer = Timer.periodic(interval, (_) => _checkAfluencia());

    // Ejecutar una primera vez de inmediato
    _checkAfluencia();
  }

  /// Detiene el monitoreo.
  void stopMonitoring() {
    _timer?.cancel();
    _timer = null;
    _lastNotificationTimes.clear(); // Limpiar memoria al detener
    if (kDebugMode) {
      print('AfluenciaMonitorService: Monitoreo detenido.');
    }
  }

  Future<void> _checkAfluencia() async {
    final prefs = await SharedPreferences.getInstance();

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
      (establishments) async {
        if (kDebugMode) {
          print(
              'AfluenciaMonitorService: ${establishments.length} establecimientos obtenidos.');
        }

        // Obtener cooldown configurado (default 2 horas = 120 min)
        final cooldownMinutes =
            prefs.getInt(AppConfig.notificationCooldownKey) ?? 120;
        final cooldownDuration = Duration(minutes: cooldownMinutes);

        for (final est in establishments) {
          // ENH-150: Lógica para detectar baja afluencia
          if (est.isOpen && est.occupancyLevel == 1) {
            
            // ENH-152: Control de frecuencia (Cooldown)
            if (_shouldNotify(est.id, cooldownDuration)) {
              if (kDebugMode) {
                print(
                    'AfluenciaMonitorService: DISPARANDO notificación para ${est.name}');
              }

              final payload = NotificationPayload(
                establishmentId: est.id,
                establishmentName: est.name,
                afluenciaLevel:
                    _calculateAfluenciaPercentage(est.averageWaitMinutes),
              );

              await NotificationService().showNotification(payload);
              
              // Registrar hora de envío
              _lastNotificationTimes[est.id] = DateTime.now();
            } else {
              if (kDebugMode) {
                print(
                    'AfluenciaMonitorService: Omitiendo ${est.name} (dentro del cooldown de $cooldownMinutes min)');
              }
            }
          }
        }
      },
    );
  }

  /// Verifica si ha pasado suficiente tiempo desde la última notificación
  /// para el establecimiento dado.
  bool _shouldNotify(String id, Duration cooldown) {
    final lastTime = _lastNotificationTimes[id];
    if (lastTime == null) return true;
    
    final difference = DateTime.now().difference(lastTime);
    return difference >= cooldown;
  }

  /// Calcula un porcentaje aproximado de afluencia basado en minutos de espera
  /// (Asumimos 15 min = 100%).
  int _calculateAfluenciaPercentage(int? minutes) {
    if (minutes == null) {
      return 10; // Valor base bajo si no hay dato pero está abierto
    }
    const maxWait = 15;
    final percentage = (minutes / maxWait * 100).round();
    return percentage.clamp(5, 100);
  }
}
