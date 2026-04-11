import 'package:enhorario/features/notifications/domain/entities/notification_status.dart';
import 'package:enhorario/features/notifications/domain/repositories/notification_repository.dart';
import 'package:enhorario/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
    final status = await _repository.getStatus();
    emit(state.copyWith(status: status));
  }

  Future<void> requestPermissions() async {
    emit(
      state.copyWith(
        status: NotificationStatus.loading,
        clearErrorMessage: true,
      ),
    );

    try {
      final status = await _repository.requestStatus();

      if (status == NotificationStatus.granted) {
        emit(
          state.copyWith(
            status: status,
            clearErrorMessage: true,
          ),
        );
      } else if (status == NotificationStatus.permanentlyDenied) {
        emit(state.copyWith(
          status: status,
          errorMessage:
              'Permisos bloqueados permanentemente. Por favor, habilítalos en ajustes.',
        ));
      } else {
        emit(state.copyWith(
          status: status,
          errorMessage: 'Los permisos de notificación fueron denegados.',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        status: NotificationStatus.error,
        errorMessage: 'Error inesperado al solicitar permisos: $e',
      ));
    }
  }

  Future<void> toggleNotifications(bool value) async {
    if (!value) {
      // Deshabilitar: actualizar estado y preferencias de inmediato
      emit(state.copyWith(isNotificationsEnabled: false));
      try {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool(_notificationsPrefsKey, false);
      } catch (_) {}
      return;
    }

    // Habilitar: solicitar permisos primero y solo activar si son concedidos
    await requestPermissions();

    final granted = state.status == NotificationStatus.granted;
    emit(state.copyWith(isNotificationsEnabled: granted));

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsPrefsKey, granted);
    } catch (_) {
      // Loguear error en una app real
    }
  }
}
