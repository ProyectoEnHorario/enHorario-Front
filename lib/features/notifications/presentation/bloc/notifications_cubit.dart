import 'package:enhorario/features/notifications/domain/repositories/notification_repository.dart';
import 'package:enhorario/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState()) {
    _loadSettings();
  }

  final NotificationRepository _repository;
  static const String _notificationsPrefsKey = 'is_notifications_enabled';

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final isEnabled = prefs.getBool(_notificationsPrefsKey) ?? true;
      emit(state.copyWith(isNotificationsEnabled: isEnabled));
    } catch (_) {
      // Si falla shared_preferences, mantenemos el default
    }
  }

  Future<void> checkStatus() async {
    final status = await Permission.notification.status;
    
    if (status.isGranted) {
      emit(state.copyWith(status: NotificationStatus.granted));
    } else if (status.isPermanentlyDenied) {
      emit(state.copyWith(status: NotificationStatus.permanentlyDenied));
    } else {
      emit(state.copyWith(status: NotificationStatus.denied));
    }
  }

  Future<void> requestPermissions() async {
    emit(state.copyWith(status: NotificationStatus.loading, errorMessage: null));
    
    final status = await Permission.notification.request();
    
    if (status.isGranted) {
      emit(state.copyWith(status: NotificationStatus.granted));
    } else if (status.isPermanentlyDenied) {
      emit(state.copyWith(
        status: NotificationStatus.permanentlyDenied,
        errorMessage: 'Permisos bloqueados permanentemente. Por favor, habilítalos en ajustes.',
      ));
    } else {
      emit(state.copyWith(
        status: NotificationStatus.denied,
        errorMessage: 'Los permisos de notificación fueron denegados.',
      ));
    }
  }

  Future<void> toggleNotifications(bool value) async {
    emit(state.copyWith(isNotificationsEnabled: value));
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsPrefsKey, value);
    } catch (_) {
      // Log error in real app
    }
  }
}
