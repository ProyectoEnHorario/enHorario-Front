import 'package:equatable/equatable.dart';
import 'package:enhorario/features/notifications/domain/entities/notification_status.dart';

class NotificationsState extends Equatable {
  const NotificationsState({
    this.status = NotificationStatus.initial,
    this.isNotificationsEnabled = true, // Configuración de la App
    this.errorMessage,
  });

  final NotificationStatus status;
  final bool isNotificationsEnabled;
  final String? errorMessage;

  NotificationsState copyWith({
    NotificationStatus? status,
    bool? isNotificationsEnabled,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
      errorMessage: clearErrorMessage ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [status, isNotificationsEnabled, errorMessage];
}
