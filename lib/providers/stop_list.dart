import 'dart:convert';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:latlong2/latlong.dart';
import 'package:kdtree/kdtree.dart';
import 'package:quick_bus/helpers/database.dart';
import 'package:quick_bus/models/bus_stop.dart';
import 'package:quick_bus/models/location.dart';
import 'package:diacritic/diacritic.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';

final stopsProvider = Provider((ref) => StopList._());

class StopsDownloadError extends Error {
  final String message;
  StopsDownloadError(this.message);
}

class StopList {
  Map<String, BusStop> _stops = {};
  KDTree? _tree;

  // Disallowing instantiating this class elsewhere.
  StopList._();

  Future loadBusStops() async {
    var stops = await _getStopsFromDatabase();
    if (stops.isEmpty) {
      print('No stops in the database, reading from file.');
      final data = await rootBundle.loadString('assets/stops.txt');
      stops = _parseStopCSV(data);
    }
    _updateStopTree(stops);
    // Start background downloading of new stops if needed
    _updateStopsInDatabase();
  }

  List<BusStop> findNearestStops(LatLng location,
      {int count = 3, double maxDistance = 500.0}) {
    if (_tree == null) return [];
    var nearest = _tree!.nearest(_makeKDPoint(location), count);
    final distance = DistanceEquirectangular();
    return <BusStop>[for (List v in nearest) v[0]['stop']]
        .where((stop) => distance(location, stop.location) <= maxDistance)
        .toList();
  }

  BusStop? resolveStop(BusStop template) {
    if (_tree == null) return null;
    var nearest = _tree!.nearest(_makeKDPoint(template.location), 3);
    if (nearest.isEmpty) return null;
    List<BusStop> stops = nearest.map((e) => e[0]['stop'] as BusStop).toList();
    final distance = DistanceEquirectangular();
    stops.sort((a, b) => distance(template.location, a.location)
        .compareTo(distance(template.location, b.location)));
    return stops.firstWhere((stop) => stop.name == template.name);
  }

  List<BusStop> findStopsByName(String part,
      {LatLng? around, int max = 3, bool deduplicate = false}) {
    part = _normalize(part);
    List<BusStop> stops = _stops.values
        .where(
            (stop) => _normalize(stop.name).contains(part))
        .toList();
    if (around != null) {
      final distance = DistanceEquirectangular();
      stops.sort((a, b) =>
          distance(around, a.location).compareTo(distance(around, b.location)));
    }
    if (deduplicate) {
      // Code from https://stackoverflow.com/a/63277386
      final names = Set();
      stops.retainWhere((element) => names.add(element.name));
    }
    // Put stops with names that start with part first.
    mergeSort(stops, compare: (BusStop a, BusStop b) {
      final hasPrefixA = _normalize(a.name).startsWith(part);
      final hasPrefixB = _normalize(b.name).startsWith(part);
      if (hasPrefixA == hasPrefixB) return 0;
      return hasPrefixA ? -1 : 1;
    });
    if (stops.length > max) stops = stops.sublist(0, max);
    return stops;
  }

  // Private methods down below /////////////////////////////////////////////

  String _normalize(String name) => removeDiacritics(name).toLowerCase();

  Map<String, dynamic> _makeKDPoint(LatLng location) {
    return {
      'y': location.latitudeInRad,
      'x': location.longitudeInRad * math.cos(location.latitudeInRad / 2),
    };
  }

  _updateStopTree(List<BusStop> stops) {
    List<Map<String, dynamic>> treePoints = [
      for (var stop in stops)
        {
          ..._makeKDPoint(stop.location),
          'stop': stop,
        }
    ];
    var rectDistance =
        (a, b) => math.pow(a['x'] - b['x'], 2) + math.pow(a['y'] - b['y'], 2);
    _tree = KDTree(treePoints, rectDistance, ['x', 'y']);
    _stops = {for (var stop in stops) stop.gtfsId: stop};
  }

  Future _updateStopsInDatabase() async {
    const STOPS_UPDATE_TIMESTAMP = 'stops_update_timestamp';
    final preferences = await SharedPreferences.getInstance();
    final lastDownloadDate = preferences.getInt(STOPS_UPDATE_TIMESTAMP);
    if (lastDownloadDate == null ||
        DateTime.fromMillisecondsSinceEpoch(lastDownloadDate)
            .add(Duration(days: 1))
            .isBefore(DateTime.now())) {
      // Stops got old
      final stops;
      try {
        stops = await _downloadStops();
      } on StopsDownloadError catch (e) {
        print('Error downloading stops: ${e.message}');
        return;
      }
      _updateStopTree(stops);
      await _uploadStopsToDatabase(stops);
      await preferences.setInt(
          STOPS_UPDATE_TIMESTAMP, DateTime.now().millisecondsSinceEpoch);
    }
  }

  Future _uploadStopsToDatabase(List<SiriBusStop> stops) async {
    final db = await DatabaseHelper.db.database;
    await db.transaction((txn) async {
      await txn.delete(DatabaseHelper.STOPS);
      final batch = txn.batch();
      for (var stop in stops) {
        batch.insert(DatabaseHelper.STOPS, stop.toJson());
      }
      await batch.commit(noResult: true);
    });
  }

  Future<List<SiriBusStop>> _getStopsFromDatabase() async {
    final db = await DatabaseHelper.db.database;
    final result = await db.query(
      DatabaseHelper.STOPS,
      columns: ['gtfsId', 'siriId', 'lat', 'lon', 'name'],
    );
    return [for (var stop in result) SiriBusStop.fromJson(stop)];
  }

  List<SiriBusStop> _parseStopCSV(String data) {
    final parser = CsvToListConverter(
      fieldDelimiter: ';',
      shouldParseNumbers: false,
      eol: '\n',
    );
    final List<SiriBusStop> newStops = [];
    String lastName = '';
    for (var row in parser.convert(data)) {
      if (row[0] == 'ID') continue;
      final strRow = [for (var part in row) part.toString()];
      if (strRow.length >= 6 && strRow[5].isNotEmpty) lastName = strRow[5];
      if (SiriBusStop.validate(strRow))
        newStops.add(SiriBusStop.fromList(strRow, lastName));
    }
    return newStops;
  }

  Future<List<SiriBusStop>> _downloadStops() async {
    var response =
        await http.get(Uri.https('transport.tallinn.ee', '/data/stops.txt'));

    if (response.statusCode != 200) {
      throw StopsDownloadError('Failed to load stops: ${response.statusCode}');
    }
    final result = _parseStopCSV(utf8.decode(response.bodyBytes));
    if (result.length < 100)
      throw StopsDownloadError(
          'Got only ${result.length} stops, must be an error.');
    return result;
  }
}
