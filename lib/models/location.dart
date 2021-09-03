import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'dart:math' as math;

class Location {
  final double latitude;
  final double longitude;

  const Location({required this.latitude, required this.longitude});
  Location.fromLatLng(LatLng loc) : latitude = loc.latitude, longitude = loc.longitude;

  String toString() {
    return '$latitude, $longitude';
  }

  LatLng toLatLng() {
    return LatLng(latitude, longitude);
  }

  static Future<LatLng> getCurrentLocation() async {
    final loc = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
      timeLimit: Duration(seconds: 10),
    );
    // return Location(latitude: loc.latitude, longitude: loc.longitude);
    return LatLng(loc.latitude, loc.longitude);
  }
}

class Equirectangular extends Haversine {
  const Equirectangular();

  @override
  double distance(LatLng p1, LatLng p2) {
    final f1 = p1.latitudeInRad;
    final f2 = p2.latitudeInRad;
    final x = (p2.longitudeInRad - p1.longitudeInRad) * math.cos((f1 + f2) / 2);
    final y = f2 - f1;
    return math.sqrt(x*x + y*y) * earthRadius;
  }
}

class DistanceEquirectangular extends Distance {
  const DistanceEquirectangular({final bool roundResult = true})
    : super(roundResult: roundResult, calculator: const Equirectangular());
}