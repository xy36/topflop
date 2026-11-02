import 'dart:convert';

import 'package:http/http.dart' as http;

class NearbyShop {
  const NearbyShop({required this.name, required this.latitude, required this.longitude, this.address});

  final String name;
  final String? address;
  final double latitude;
  final double longitude;
}

/// Sucht Geschäfte in der Nähe über die OpenStreetMap-Overpass-API.
class OverpassClient {
  OverpassClient({http.Client? httpClient}) : _http = httpClient ?? http.Client();

  final http.Client _http;

  static final _endpoint = Uri.https('overpass-api.de', '/api/interpreter');
  static const _shopTypes = 'supermarket|convenience|butcher|bakery|greengrocer|deli|chemist|organic|cheese|beverages';

  Future<List<NearbyShop>> shopsAround(double lat, double lon, {int radiusMeters = 1500}) async {
    final query = '[out:json][timeout:10];'
        'nwr(around:$radiusMeters,$lat,$lon)["shop"~"^($_shopTypes)\$"]["name"];'
        'out center 40;';
    final response = await _http
        .post(_endpoint, body: {'data': query}, headers: {'User-Agent': 'Nochmal/1.0 (Flutter)'})
        .timeout(const Duration(seconds: 12));
    if (response.statusCode != 200) return const [];

    final json = jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>;
    final elements = (json['elements'] as List?) ?? const [];
    return [
      for (final e in elements.cast<Map<String, dynamic>>())
        if (_coords(e) case (final la, final lo))
          NearbyShop(
            name: (e['tags'] as Map)['name'] as String,
            address: _address(e['tags'] as Map),
            latitude: la,
            longitude: lo,
          ),
    ];
  }

  static (double, double)? _coords(Map<String, dynamic> e) {
    final center = e['center'] as Map<String, dynamic>?;
    final lat = (e['lat'] ?? center?['lat']) as num?;
    final lon = (e['lon'] ?? center?['lon']) as num?;
    if (lat == null || lon == null) return null;
    return (lat.toDouble(), lon.toDouble());
  }

  static String? _address(Map tags) {
    final street = tags['addr:street'] as String?;
    if (street == null) return null;
    final number = tags['addr:housenumber'] as String?;
    return number == null ? street : '$street $number';
  }
}
