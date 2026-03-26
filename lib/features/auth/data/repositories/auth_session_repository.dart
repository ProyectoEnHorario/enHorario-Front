import 'package:enhorario/core/config/app_config.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthSessionRepository {
  static String? _tokenFallback;
  static String? _userFallback;
  static String? _roleFallback;

  Future<void> saveSession({
    required String token,
    required String email,
    String? role,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConfig.authTokenKey, token);
      await prefs.setString(AppConfig.userKey, email);
      if (role != null && role.trim().isNotEmpty) {
        await prefs.setString(AppConfig.userRoleKey, role.trim());
      }
      _tokenFallback = token;
      _userFallback = email;
      _roleFallback = role?.trim();
    } on MissingPluginException {
      _tokenFallback = token;
      _userFallback = email;
      _roleFallback = role?.trim();
    } on PlatformException {
      _tokenFallback = token;
      _userFallback = email;
      _roleFallback = role?.trim();
    }
  }

  Future<bool> hasSession() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConfig.authTokenKey);
      if (token != null && token.trim().isNotEmpty) {
        _tokenFallback = token;
        _userFallback = prefs.getString(AppConfig.userKey);
        _roleFallback = prefs.getString(AppConfig.userRoleKey);
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
    _roleFallback = null;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(AppConfig.authTokenKey);
      await prefs.remove(AppConfig.userKey);
      await prefs.remove(AppConfig.userRoleKey);
    } on MissingPluginException {
      return;
    } on PlatformException {
      return;
    }
  }

  Future<String?> getAuthToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConfig.authTokenKey) ?? _tokenFallback;
    } on MissingPluginException {
      return _tokenFallback;
    } on PlatformException {
      return _tokenFallback;
    }
  }

  Future<String?> getCurrentUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConfig.userKey) ?? _userFallback;
    } on MissingPluginException {
      return _userFallback;
    } on PlatformException {
      return _userFallback;
    }
  }

  Future<String?> getCurrentUserRole() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(AppConfig.userRoleKey) ?? _roleFallback;
    } on MissingPluginException {
      return _roleFallback;
    } on PlatformException {
      return _roleFallback;
    }
  }

  Future<bool> isCurrentUserAdmin() async {
    final role = (await getCurrentUserRole())?.trim().toLowerCase();
    if (role == 'admin' || role == 'administrador') {
      return true;
    }

    // Fallback compatible con ambientes donde el backend no retorna rol en login.
    final email = (await getCurrentUserEmail())?.trim().toLowerCase();
    return email == 'admin@enhorario.com';
  }
}
