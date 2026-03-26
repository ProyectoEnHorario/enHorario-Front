/// Configuración central de la aplicación
class AppConfig {
  // Backend API
  static const String backendBaseUrl = String.fromEnvironment(
    'BACKEND_URL',
    defaultValue: 'https://enhorarioback-production.up.railway.app/api/v1',
  );

  static const String apiVersion = 'v1';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);

  // Storage Keys
  static const String authTokenKey = 'auth_token';
  static const String userKey = 'current_user';
  static const String userRoleKey = 'current_user_role';
}
