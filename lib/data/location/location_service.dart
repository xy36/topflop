import 'package:geolocator/geolocator.dart';

class LatLon {
  const LatLon(this.latitude, this.longitude);

  final double latitude;
  final double longitude;

  double distanceTo(double lat, double lon) => Geolocator.distanceBetween(latitude, longitude, lat, lon);
}

/// Kapselt Standortabfrage inklusive Berechtigungen. Liefert `null`, wenn der
/// Standort nicht verfügbar ist – die App funktioniert dann ohne.
class LocationService {
  Future<LatLon?> currentPosition() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) return null;

      Position? position;
      try {
        position = await Geolocator.getCurrentPosition(
          locationSettings: const LocationSettings(accuracy: LocationAccuracy.high, timeLimit: Duration(seconds: 8)),
        );
      } catch (_) {
        // Im Laden ist der GPS-Empfang oft schlecht: letzte bekannte Position reicht.
        position = await Geolocator.getLastKnownPosition();
      }
      return position == null ? null : LatLon(position.latitude, position.longitude);
    } catch (_) {
      return null;
    }
  }
}

/// Formatiert Entfernungen wie im Design: „40 m“, „1,2 km“.
String formatDistance(double meters, String locale) {
  if (meters < 1000) return '${(meters / 10).round() * 10} m';
  final km = (meters / 1000).toStringAsFixed(1);
  return '${locale.startsWith('de') ? km.replaceAll('.', ',') : km} km';
}
