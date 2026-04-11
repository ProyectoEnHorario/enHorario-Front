import 'dart:io';
import 'package:enhorario/core/errors/failure.dart';
import 'package:enhorario/core/navigation/navigation_service.dart';
import 'package:enhorario/core/results/result.dart';
import 'package:enhorario/features/establishments/presentation/pages/pantalla_detalle_tiempo_espera_establecimiento.dart';
import 'package:enhorario/features/notifications/domain/entities/app_notification.dart';
import 'package:enhorario/features/notifications/domain/entities/notification_status.dart';
import 'package:enhorario/features/notifications/domain/repositories/notification_repository.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';

class LocalNotificationRepository implements NotificationRepository {
  LocalNotificationRepository({
    FlutterLocalNotificationsPlugin? plugin,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  static const String _channelId = 'afluencia_channel';
  static const String _channelName = 'Notificaciones de Afluencia';
  static const String _channelDescription = 
      'Notifica cuando un establecimiento favorito tiene baja afluencia.';

  @override
  Future<Result<void>> initialize() async {
    try {
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const DarwinInitializationSettings initializationSettingsDarwin =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      const InitializationSettings initializationSettings = InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsDarwin,
      );

      await _plugin.initialize(
        initializationSettings,
        onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
      );

      final androidPlugin = _plugin.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      
      if (androidPlugin != null) {
        const AndroidNotificationChannel channel = AndroidNotificationChannel(
          _channelId,
          _channelName,
          description: _channelDescription,
          importance: Importance.max,
        );
        await androidPlugin.createNotificationChannel(channel);
      }

      return const Right(null);
    } catch (e) {
      return Left(Failure('Error al inicializar notificaciones: $e'));
    }
  }

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    final payload = response.payload;
    if (payload != null && payload.isNotEmpty) {
      NavigationService.navigateTo(
        PantallaDetalleTiempoEsperaEstablecimiento(establishmentId: payload),
      );
    }
  }

  @override
  Future<Result<void>> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        _channelId,
        _channelName,
        channelDescription: _channelDescription,
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      );

      const NotificationDetails platformDetails = NotificationDetails(
        android: androidDetails,
        iOS: DarwinNotificationDetails(),
      );

      await _plugin.show(
        id,
        title,
        body,
        platformDetails,
        payload: payload,
      );

      return const Right(null);
    } catch (e) {
      return Left(Failure('Error al mostrar notificación: $e'));
    }
  }

  @override
  Future<Result<void>> showAppNotification(AppNotification notification) {
    return showNotification(
      id: notification.id,
      title: notification.title,
      body: notification.body,
      payload: notification.payload,
    );
  }

  @override
  Future<bool> requestPermissions() async {
    if (Platform.isAndroid) {
      final status = await Permission.notification.request();
      return status.isGranted;
    } else if (Platform.isIOS) {
      final bool? result = await _plugin
          .resolvePlatformSpecificImplementation<
              IOSFlutterLocalNotificationsPlugin>()
          ?.requestPermissions(
            alert: true,
            badge: true,
            sound: true,
          );
      return result ?? false;
    }
    return false;
  }

  @override
  Future<NotificationStatus> getStatus() async {
    final status = await Permission.notification.status;
    return _mapPermissionStatus(status);
  }

  @override
  Future<NotificationStatus> requestStatus() async {
    final status = await Permission.notification.request();
    return _mapPermissionStatus(status);
  }

  NotificationStatus _mapPermissionStatus(PermissionStatus status) {
    if (status.isGranted) return NotificationStatus.granted;
    if (status.isPermanentlyDenied) return NotificationStatus.permanentlyDenied;
    if (status.isDenied) return NotificationStatus.denied;
    return NotificationStatus.error;
  }

  @override
  Future<bool> isEnabled() async {
    return await Permission.notification.isGranted;
  }

  @override
  Future<void> cancelAll() async {
    await _plugin.cancelAll();
  }
}
