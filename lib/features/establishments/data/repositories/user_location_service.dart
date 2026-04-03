import 'package:geolocator/geolocator.dart';

class UserLocationResult {
  const UserLocationResult({
    required this.position,
    required this.permissionDenied,
    required this.message,
  });

  final Position? position;
  final bool permissionDenied;
  final String? message;
}

class UserLocationService {
  static const double fallbackLatitude = 4.7110;
  static const double fallbackLongitude = -74.0721;

  Future<UserLocationResult> getCurrentPosition() async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return const UserLocationResult(
        position: null,
        permissionDenied: false,
        message:
            'Activa el GPS para mostrar establecimientos cercanos con precision.',
      );
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return const UserLocationResult(
        position: null,
        permissionDenied: true,
        message:
            'Permiso de ubicacion denegado. Se mostrara una ubicacion por defecto.',
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 10,
        ),
          ).timeout(const Duration(seconds: 8));

      return UserLocationResult(
        position: position,
        permissionDenied: false,
        message: null,
      );
    } catch (_) {
      return const UserLocationResult(
        position: null,
        permissionDenied: false,
        message:
            'No fue posible obtener la ubicacion actual. Se mostrara una ubicacion por defecto.',
      );
    }
  }
}
