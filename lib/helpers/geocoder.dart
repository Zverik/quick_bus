import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/constants.dart';
import 'dart:convert';

class GeocoderError extends Error {
  final String message;

  GeocoderError(this.message);
}

class GeocoderResponseItem {
  final LatLng location;
  final String type;
  final String? name;
  final String? city;
  final String? street;
  final String? house;
  final String? locality;
  final String? district;
  final String osmKey;
  final String osmValue;

  GeocoderResponseItem({
    required this.location,
    required this.type,
    required this.osmKey,
    required this.osmValue,
    this.name,
    this.city,
    this.street,
    this.house,
    this.locality,
    this.district,
  });

  static const poiKeys = <String>{
    'natural',
    'amenity',
    'shop',
    'tourism',
    'historic',
    'man_made'
  };

  String get title {
    String trueType;
    if (poiKeys.contains(osmKey))
      trueType = osmValue;
    else if (osmKey == 'building')
      trueType = 'building';
    else
      trueType = type;
    if (name == null) {
      // Return a short address for a title
      String? addr = [street, house].where((e) => e != null).join(', ');
      if (addr.isEmpty)
        addr = [locality, district, city].firstWhere((e) => e != null);
      return addr ?? trueType;
    }
    return '$name, $trueType';
  }

  String get address {
    String houseAddress = [street, house].where((e) => e != null).join(' ');
    String loc = [name != null ? houseAddress : null, locality, district, city]
        .where((e) => e != null && e.isNotEmpty)
        .join(', ');
    return loc;
  }
}

class AutocompleteGeocoder {
  Future<List<GeocoderResponseItem>> query(String q, [LatLng? around]) async {
    var response = await http.get(Uri.http(kPhotonEndpoint, '/api', {
      'q': q,
      'limit': '10',
      'lang': 'en',
      if (around != null) ...{
        'lat': around.latitude.toString(),
        'lon': around.longitude.toString(),
      }
    }));

    if (response.statusCode == 200) {
      dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
      List<GeocoderResponseItem> result = [];
      for (var feature in data['features']) {
        List c = feature['geometry']['coordinates'];
        Map<String, dynamic> p = feature['properties'];
        result.add(GeocoderResponseItem(
          location: LatLng(c[1], c[0]),
          type: p['type'],
          name: p['name'],
          osmKey: p['osm_key'],
          osmValue: p['osm_value'],
          city: p['city'],
          street: p['street'],
          house: p['housenumber'],
          district: p['district'],
          locality: p['locality'],
        ));
      }
      return result;
    } else {
      throw GeocoderError('Geocoder is not answering: ${response.statusCode}');
    }
  }
}
