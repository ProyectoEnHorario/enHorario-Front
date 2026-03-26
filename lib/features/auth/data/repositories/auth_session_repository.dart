import 'package:enhorario/core/config/app_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionRepository {
  Future<void> saveSession({required String token, required String email}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(AppConfig.authTokenKey, token);
    await prefs.setString(AppConfig.userKey, email);
  }

  Future<bool> hasSession() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConfig.authTokenKey);
    return token != null && token.trim().isNotEmpty;
  }

  Future<void> clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConfig.authTokenKey);
    await prefs.remove(AppConfig.userKey);
  }
}
