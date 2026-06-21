import 'package:geolocator/geolocator.dart';

/// Wrapper de geolocalización. Devuelve la posición del dispositivo o null si
/// el servicio está apagado, el permiso fue denegado o hubo timeout/error.
/// Nunca lanza: la app cae con gracia a la ciudad por defecto.
class LocationService {
  Future<Position?> currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.low,
          timeLimit: Duration(seconds: 8),
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
