import 'package:latlong2/latlong.dart';
import 'package:diacritic/diacritic.dart';
import 'package:proximity_hash/geohash.dart';
import 'package:proximity_hash/proximity_hash.dart';
import 'package:quick_bus/constants.dart';

class BusStop {
  final String gtfsId;
  final LatLng location;
  String name; // Can be updated from otherIds.
  String? address;

  BusStop({
    required this.gtfsId,
    required this.location,
    required this.name,
    this.address,
  });

  String get nameAddress =>
      address == null || address!.isEmpty ? name : '$name ($address)';

  String get normalizedName => normalizeName(name);

  static String normalizeName(String name) => removeDiacritics(name).toLowerCase();

  @override
  operator ==(other) => other is BusStop && other.gtfsId == gtfsId;

  @override
  int get hashCode => gtfsId.hashCode;

  @override
  String toString() => 'Stop($name, gtfs: $gtfsId)';

  copyWithName(String name) => BusStop(
        gtfsId: gtfsId,
        location: location,
        name: name,
        address: address,
      );
}

class SiriBusStop extends BusStop {
  final String siriId;
  final List<String> otherIds;

  SiriBusStop(
      {required String gtfsId,
      required String name,
      required LatLng location,
      required this.siriId,
      this.otherIds = const []})
      : super(
          gtfsId: gtfsId,
          name: name,
          location: location,
        );

  factory SiriBusStop.fromJson(Map<String, dynamic> json) {
    return SiriBusStop(
      gtfsId: json['gtfsId'],
      name: json['name'],
      location: LatLng(json['lat'], json['lon']),
      siriId: json['siriId'],
    );
  }

  factory SiriBusStop.fromList(List<String> parts, [String backupName = '']) {
    // ID;SiriID;Lat;Lng;Stops;Name;Info;Street;Area;City;Pikas2020.4.8
    return SiriBusStop(
        gtfsId: parts[0],
        siriId: parts[1],
        location: LatLng(
          double.parse(parts[2]) / 100000,
          double.parse(parts[3]) / 100000,
        ),
        name: parts.length >= 6 ? parts[5] : backupName,
        otherIds: parts[4].split(','));
  }

  static bool validate(List<String> parts) {
    if (parts.length < 5) return false;
    if (parts.sublist(0, 4).any((element) => element.length == 0)) return false;
    if (parts[4].length + (parts.length < 6 ? 0 : parts[5].length) == 0)
      return false;
    try {
      if (double.parse(parts[2]) < 5700000) return false;
      if (double.parse(parts[3]) < 2100000) return false;
    } on FormatException catch (e) {
      print(parts);
      throw e;
    }
    return true;
  }

  @override
  String toString() => 'Stop($name, gtfs: $gtfsId, siri: $siriId)';

  Map<String, dynamic> toJson() {
    return {
      'gtfsId': gtfsId,
      'siriId': siriId,
      'lat': location.latitude,
      'lon': location.longitude,
      'name': name,
      'norm_name': normalizedName,
      'geohash': GeoHasher().encode(
        location.longitude,
        location.latitude,
        precision: kGeohashPrecision,
      ),
    };
  }

  static const dbColumns = ['gtfsId', 'siriId', 'lat', 'lon', 'name'];
}
