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
    this.notificationsEnabled = true, // Configuración de la App
    this.errorMessage,
  });

  final NotificationStatus status;
  final bool notificationsEnabled;
  final String? errorMessage;

  NotificationsState copyWith({
    NotificationStatus? status,
    bool? notificationsEnabled,
    String? errorMessage,
  }) {
    return NotificationsState(
      status: status ?? this.status,
      notificationsEnabled: notificationsEnabled ?? this.notificationsEnabled,
      errorMessage: errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [status, notificationsEnabled, errorMessage];
}
