import 'package:enhorario/features/notifications/domain/repositories/notification_repository.dart';
import 'package:enhorario/features/notifications/presentation/bloc/notifications_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  NotificationsCubit(this._repository) : super(const NotificationsState());

  final NotificationRepository _repository;

  Future<void> checkStatus() async {
    final isEnabled = await _repository.isEnabled();
    emit(state.copyWith(
      status: isEnabled ? NotificationStatus.granted : NotificationStatus.denied,
    ));
  }

  Future<void> requestPermissions() async {
    emit(state.copyWith(status: NotificationStatus.loading));
    
    final granted = await _repository.requestPermissions();
    
    emit(state.copyWith(
      status: granted ? NotificationStatus.granted : NotificationStatus.denied,
    ));
  }

  void toggleNotifications(bool value) {
    // Solo cambia la preferencia del usuario en la App
    emit(state.copyWith(notificationsEnabled: value));
  }
}
