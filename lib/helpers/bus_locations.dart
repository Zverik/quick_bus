import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/models/modes.dart';
import 'package:quick_bus/models/route.dart';
import 'package:csv/csv.dart';

class BusLocation {
  final TransitRoute route;
  final LatLng location;
  final int direction;

  const BusLocation(this.route, this.location, this.direction);

  BusLocation updateLocation(LatLng location) {
    return BusLocation(route, location, direction);
  }
}

class BusLocations {
  static const kGpsModes = <String, TransitMode>{
    '1': TransitMode.trolleybus,
    '2': TransitMode.bus,
    '3': TransitMode.tram,
  };

  Future<List<BusLocation>> getLocations(TransitRoute route) async {
    final List<BusLocation> result = await queryLocations();
    return result
        .where((loc) =>
            loc.route.mode == route.mode && loc.route.number == route.number)
        .toList(growable: false);
  }

  Future<List<BusLocation>> queryLocations() async {
    var response =
        await http.get(Uri.https('transport.tallinn.ee', '/gps.txt'));
    if (response.statusCode != 200) return const [];
    final parser = CsvToListConverter(
      eol: '\n',
      shouldParseNumbers: false,
    );
    var data = parser.convert(response.body);
    final List<BusLocation> result = [];
    for (var row in data) {
      final mode = kGpsModes[row[0]];
      if (mode != null) {
        final location = LatLng(
            double.parse(row[3]) / 1000000, double.parse(row[2]) / 1000000);
        result.add(BusLocation(
          // fake headsign
          TransitRoute(mode: mode, number: row[1], headsign: ''),
          location,
          int.parse(row[5]),
        ));
      }
    }
    return result;
  }
}
