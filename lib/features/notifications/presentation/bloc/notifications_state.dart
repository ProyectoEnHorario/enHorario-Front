import 'package:equatable/equatable.dart';

enum NotificationStatus {
  initial,
  loading,
  granted,
  denied,
  permanentlyDenied,
  error,
}

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
  }) {
    return NotificationsState(
      status: status ?? this.status,
      isNotificationsEnabled: isNotificationsEnabled ?? this.isNotificationsEnabled,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, isNotificationsEnabled, errorMessage];
}
