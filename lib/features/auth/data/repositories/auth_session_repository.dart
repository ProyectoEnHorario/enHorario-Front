import 'package:enhorario/core/config/app_config.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionRepository {
  static String? _tokenFallback;
  static String? _userFallback;

  Future<void> saveSession({required String token, required String email}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.authTokenKey, token);
      await prefs.setString(AppConfig.userKey, email);
      _tokenFallback = token;
      _userFallback = email;
    } on MissingPluginException {
      _tokenFallback = token;
      _userFallback = email;
    } on PlatformException {
      _tokenFallback = token;
      _userFallback = email;
    }
  }

  Future<bool> hasSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.authTokenKey);
      if (token != null && token.trim().isNotEmpty) {
        _tokenFallback = token;
        _userFallback = prefs.getString(AppConfig.userKey);
        return true;
      }
      return _tokenFallback != null && _tokenFallback!.trim().isNotEmpty;
    } on MissingPluginException {
      return _tokenFallback != null && _tokenFallback!.trim().isNotEmpty;
    } on PlatformException {
      return _tokenFallback != null && _tokenFallback!.trim().isNotEmpty;
    }
  }

  Future<void> clearSession() async {
    _tokenFallback = null;
    _userFallback = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConfig.authTokenKey);
      await prefs.remove(AppConfig.userKey);
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }
}
