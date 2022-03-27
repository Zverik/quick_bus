import 'dart:convert' show utf8, jsonDecode;
import 'package:intl/intl.dart' show DateFormat;
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'package:quick_bus/models/arrival.dart';
import 'package:quick_bus/models/bus_stop.dart';
import 'package:quick_bus/models/route.dart';
import 'package:quick_bus/models/route_element.dart';
import 'package:quick_bus/constants.dart';
import 'package:google_polyline_algorithm/google_polyline_algorithm.dart'
    show decodePolyline;

class RouteQueryNetworkError implements Exception {
  int statusCode;
  Uri uri;

  RouteQueryNetworkError(this.statusCode, this.uri);
}

class RouteQueryOTPError implements Exception {
  String message;
  Uri? uri;

  RouteQueryOTPError(this.message, [this.uri]);
}

class StopNotFoundError extends Error {}

class RouteNotFoundError extends Error {}

class PatternData {
  Path geometry;
  List<Arrival> stops;

  PatternData({required this.geometry, required this.stops});
}

class RouteQuery {
  Future<dynamic> performOTPQuery(
      String method, Map<String, String> params) async {
    var uri = Uri.http(kOTPEndpoint, '/otp/routers/default/$method', params);
    var response = await http.get(uri);

    if (response.statusCode != 200) {
      throw RouteQueryNetworkError(response.statusCode, uri);
    }

    dynamic data = jsonDecode(utf8.decode(response.bodyBytes));
    if (data == null) {
      throw RouteQueryOTPError("Empty response", uri);
    }
    if (data is Map && data.containsKey('error'))
      throw RouteQueryOTPError(data['error']['message'], uri);
    return data;
  }

  static isCityRoute(List<RouteElement> route) {
    // Length is 1 for fully pedestrian routes.
    return route.length == 1 ||
        !route.any((element) =>
            element is TransitRouteElement && !element.route.mode.isPreferred);
  }

  Future<List<List<RouteElement>>> getRouteOptions(
      LatLng from, LatLng to) async {
    final timeFormat = DateFormat('HH:mm:ss');
    final dateFormat = DateFormat('yyyy-MM-dd');
    final planBeforeDate = DateTime.now().subtract(kPlanBefore);
    var params = <String, String>{
      'fromPlace': '${from.latitude},${from.longitude}',
      'toPlace': '${to.latitude},${to.longitude}',
      'mode': 'TRANSIT,WALK',
      'showIntermediateStops': 'true',
      if (kPlanBefore.inSeconds > 0) ...{
        'time': timeFormat.format(planBeforeDate),
        'date': dateFormat.format(planBeforeDate),
      }
    };
    dynamic data;
    try {
      data = await performOTPQuery('plan', params);
      // no routes => print "path not found" to trigger the catch block.
      if (data['plan']['itineraries'].isEmpty)
        throw RouteQueryOTPError('PATH_NOT_FOUND');
    } on RouteQueryOTPError catch (e) {
      if (e.message == 'PATH_NOT_FOUND') {
        params['searchWindow'] = (3600 * 3).toString();
        data = await performOTPQuery('plan', params);
      } else
        throw e;
    }

    List<List<RouteElement>> routes = [
      for (var itinerary in data['plan']['itineraries'])
        [for (var leg in itinerary['legs']) RouteElement.fromJson(leg)]
    ];

    // If the first one is walk-only and there are others, filter it out.
    if (routes.length > 1 && routes.first.length == 1 && routes.first.first is WalkRouteElement) {
      if (routes[0].last.arrival.isAfter(routes[1].last.arrival))
        routes.removeAt(0);
    }

    // Filter out regional routes if needed
    final cityRoutes = routes.where((route) => isCityRoute(route)).toList();
    return cityRoutes.isEmpty ? routes : cityRoutes;
  }

  Future<String> findBusStopId(BusStop stop) async {
    List<dynamic> data = await performOTPQuery('index/stops', {
      'lat': stop.location.latitude.toString(),
      'lon': stop.location.longitude.toString(),
      'radius': '200',
    });
    try {
      Map<String, dynamic> matching =
          data.firstWhere((element) => element['code'] == stop.gtfsId);
      return matching['id'];
    } on StateError {
      throw StopNotFoundError();
    }
  }

  Future<String> findArrivalPattern(String stopId, Arrival arrival) async {
    // Query OTP for stop times.
    int startTime = arrival.scheduled
            .subtract(Duration(minutes: 10))
            .millisecondsSinceEpoch ~/
        1000;
    List<dynamic> data =
        await performOTPQuery('index/stops/$stopId/stoptimes', {
      'startTime': startTime.toString(),
      'timeRange': '1800', // half an hour
    });

    // Parse the stop times response.
    Map<DateTime, String> patterns = {};
    for (Map<String, dynamic> entry in data) {
      String routeId = entry['pattern']['routeId'];
      // TODO: get route from database by otpId
      var route = TransitRoute.fromGtfsIdHack(routeId);
      if (route.number != arrival.route.number ||
          route.mode != arrival.route.mode) continue;

      // Found the right route, now check times.
      for (Map<String, dynamic> time in entry['times']) {
        var scheduled = Arrival.secondsToDateTime(time['scheduledDeparture'])!;
        patterns[scheduled] = entry['pattern']['id'];
      }
    }

    // If no times found, return nothing.
    if (patterns.isEmpty) throw RouteNotFoundError();

    // Sort the patterns by distance to arrival.
    var distances = {
      for (var dt in patterns.keys) dt.difference(arrival.scheduled).abs(): dt
    };
    var minDistance = distances.keys.reduce((a, b) => a < b ? a : b);
    return patterns[distances[minDistance]]!;
  }

  Future<Path> getPatternGeometry(String patternId) async {
    Map<String, dynamic> data =
        await performOTPQuery('index/patterns/$patternId/geometry', {});
    return Path.from([
      for (List<num> pt in decodePolyline(data['points'], accuracyExponent: 5))
        LatLng(pt[0].toDouble(), pt[1].toDouble())
    ]);
  }

  Future<List<BusStop>> getPatternStops(String patternId) async {
    List<dynamic> data =
        await performOTPQuery('index/patterns/$patternId/stops', {});
    List<BusStop> result = [];
    for (var stopData in data) {
      var stop = BusStop(
        name: stopData['name'],
        gtfsId: stopData['code'],
        location: LatLng(stopData['lat'], stopData['lon']),
      );
      result.add(stop);
    }
    return result;
  }

  /// Finds a pattern for the given arrival at a given bus stop.
  Future<PatternData> getRouteGeometry(Arrival arrival) async {
    // 1. Find the bus stop in the database.
    String stopId = await findBusStopId(arrival.stop);
    // 2. Get stop times for this stop.
    // 3. Find stop time and route number that matches the arrival.
    String patternId = await findArrivalPattern(stopId, arrival);
    // 4. Find the geometry and list of stops.
    var geometry = await getPatternGeometry(patternId);
    var stops = await getPatternStops(patternId);
    // TODO: stop departure times not in OTP api.
    // 5. Return all we found.
    return PatternData(
      geometry: geometry,
      stops: [
        for (var stopData in stops)
          Arrival(
            route: arrival.route,
            stop: stopData,
            scheduled: arrival.scheduled,
          )
      ],
    );
  }

  Future<List<Arrival>> getArrivals(BusStop stop) async {
    String stopId;
    try {
      stopId = await findBusStopId(stop);
    } on StopNotFoundError {
      return [];
    }
    List<dynamic> data =
        await performOTPQuery('index/stops/$stopId/stoptimes', {
      'timeRange': '3600', // an hour
    });
    List<Arrival> arrivals = [];
    for (Map<String, dynamic> entry in data) {
      String routeId = entry['pattern']['routeId'];
      // TODO: get route from database by otpId
      var route = TransitRoute.fromGtfsIdHack(routeId);
      for (Map<String, dynamic> time in entry['times']) {
        var scheduled = Arrival.secondsToDateTime(time['scheduledDeparture'])!;
        route.headsign = time['headsign'] ?? route.headsign;
        arrivals.add(Arrival(
          route: route,
          stop: stop,
          scheduled: scheduled,
        ));
      }
    }
    arrivals.sort((a, b) => a.arrivesInSec.compareTo(b.arrivesInSec));
    return arrivals;
  }
}
