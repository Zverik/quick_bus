import 'package:latlong2/latlong.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart'
    show decodePolyline, encodePolyline;
import 'package:quick_bus/models/arrival.dart';
import 'package:quick_bus/models/modes.dart';
import 'package:quick_bus/models/route.dart';

import 'bus_stop.dart';

abstract class RouteElement {
  Path path;
  int durationSeconds;
  int distanceMeters;
  String startName;
  String endName;
  DateTime departure;
  DateTime arrival;

  RouteElement(
      {required this.path,
      required this.durationSeconds,
      required this.distanceMeters,
      required this.startName,
      required this.endName,
      required this.departure,
      required this.arrival});

  factory RouteElement.fromJson(Map<String, dynamic> json) {
    double durationSeconds = json['duration'];
    double distanceMeters = json['distance'];
    String startName = json['from']['name'];
    String endName = json['to']['name'];
    DateTime departure = DateTime.fromMillisecondsSinceEpoch(json['startTime']);
    DateTime arrival = DateTime.fromMillisecondsSinceEpoch(json['endTime']);
    var path = Path.from([
      for (List<num> pt
          in decodePolyline(json['legGeometry']['points'], accuracyExponent: 5))
        LatLng(pt[0].toDouble(), pt[1].toDouble())
    ]);

    if (!json['transitLeg']) {
      return WalkRouteElement(
        path: path,
        durationSeconds: durationSeconds.round(),
        distanceMeters: distanceMeters.round(),
        startName: startName,
        endName: endName,
        departure: departure,
        arrival: arrival,
      );
    } else {
      int stopCount = json['to']['stopIndex'] - json['from']['stopIndex'];
      final route = TransitRoute(
        mode: _getTransitModeFromId(json['routeId']),
        number: json['routeShortName'],
        headsign: json['headsign'],
      );
      return TransitRouteElement(
        path: path,
        durationSeconds: durationSeconds.round(),
        distanceMeters: distanceMeters.round(),
        startName: startName,
        endName: endName,
        departure: departure,
        arrival: arrival,
        route: route,
        stopCount: stopCount.abs(),
        intermediateStops: [
          for (var stop in json['intermediateStops'] ?? [])
            _parseStopArrival(route, stop)
        ],
      );
    }
  }

  Map<String, dynamic> toJson() {
    String polyline = encodePolyline([
      for (var coord in path.coordinates) [coord.latitude, coord.longitude]
    ], accuracyExponent: 5);
    return {
      'duration': durationSeconds.toDouble(),
      'distance': distanceMeters.toDouble(),
      'startTime': departure.millisecondsSinceEpoch,
      'endTime': arrival.millisecondsSinceEpoch,
      'legGeometry': {'points': polyline},
      'from': <String, dynamic>{
        'name': startName,
      },
      'to': <String, dynamic>{
        'name': endName,
      },
    };
  }

  /// Specific to Tallinn feed!
  static TransitMode _getTransitModeFromId(String id) {
    return TransitMode.all.firstWhere(
        (mode) => id.contains("_${mode.siriName}_"),
        orElse: () => TransitMode.bus);
  }

  static Arrival _parseStopArrival(TransitRoute route, Map<String, dynamic> json) {
    return Arrival(
      stop: BusStop(
        name: json['name'],
        gtfsId: json['stopCode'],
        location: LatLng(json['lat'], json['lon']),
      ),
      route: route,
      scheduled: DateTime.fromMillisecondsSinceEpoch(json['departure']),
    );
  }
}

class WalkRouteElement extends RouteElement {
  WalkRouteElement(
      {required Path path,
      required int durationSeconds,
      required int distanceMeters,
      required String startName,
      required String endName,
      required DateTime departure,
      required DateTime arrival})
      : super(
            path: path,
            durationSeconds: durationSeconds,
            distanceMeters: distanceMeters,
            startName: startName,
            endName: endName,
            departure: departure,
            arrival: arrival);

  @override
  Map<String, dynamic> toJson() {
    var result = super.toJson();
    result['transitLeg'] = false;
    return result;
  }
}

class TransitRouteElement extends RouteElement {
  final TransitRoute route;
  final int stopCount;
  final List<Arrival> intermediateStops;

  TransitRouteElement({
    required Path path,
    required int durationSeconds,
    required int distanceMeters,
    required String startName,
    required String endName,
    required DateTime departure,
    required DateTime arrival,
    required this.route,
    required this.stopCount,
    this.intermediateStops = const [],
  }) : super(
            path: path,
            durationSeconds: durationSeconds,
            distanceMeters: distanceMeters,
            startName: startName,
            endName: endName,
            departure: departure,
            arrival: arrival);

  @override
  Map<String, dynamic> toJson() {
    var result = super.toJson();
    String routeId = 'tll_${route.mode.siriName}_${route.number}';
    result.addAll({
      'transitLeg': true,
      'routeId': routeId,
      'routeShortName': route.number,
      'headsign': route.headsign,
    });
    result['from']['stopIndex'] = 0;
    result['to']['stopIndex'] = stopCount;
    return result;
  }
}
