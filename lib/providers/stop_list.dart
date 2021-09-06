import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:csv/csv.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/constants.dart';
import 'package:quick_bus/helpers/database.dart';
import 'package:quick_bus/models/bus_stop.dart';
import 'package:quick_bus/helpers/equirectangular.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:proximity_hash/proximity_hash.dart';
import 'package:sqflite/utils/utils.dart';

final stopsProvider = Provider((ref) => StopList._());

class StopsDownloadError extends Error {
  final String message;
  StopsDownloadError(this.message);
}

class CachedNearestStops {
  static const PRECISION = 1e4; // ~11 m
  static final dummy = CachedNearestStops(LatLng(0.0, 0.0), 0, []);

  final int _latitude;
  final int _longitude;
  final int distance;
  final List<BusStop> stops;

  CachedNearestStops(LatLng around, this.distance, this.stops)
      : _latitude = (around.latitude * PRECISION).round(),
        _longitude = (around.longitude * PRECISION).round();

  bool isSame(LatLng around, int distance) {
    return this.distance == distance &&
        _latitude == (around.latitude * PRECISION).round() &&
        _longitude == (around.longitude * PRECISION).round();
  }
}

class StopList {
  CachedNearestStops cachedNearest = CachedNearestStops.dummy;

  // Disallowing instantiating this class elsewhere.
  StopList._();

  Future loadBusStops() async {
    final firstStopRun = await _needPopulateStops();
    if (firstStopRun) {
      await _updateStopsInDatabase(force: true, fallbackToAsset: true);
    } else {
      // Start background downloading of new stops if needed
      _updateStopsInDatabase();
    }
  }

  Future<List<BusStop>> findNearestStops(LatLng location,
      {int count = 3, int maxDistance = 500}) async {
    if (cachedNearest.isSame(location, maxDistance)) return cachedNearest.stops;

    final db = await DatabaseHelper.db.database;
    final geohashes = createGeohashes(
      location.latitude,
      location.longitude,
      maxDistance.toDouble(),
      kGeohashPrecision,
    );
    final placeholders =
        List.generate(geohashes.length, (index) => "?").join(",");
    final results = await db.query(
      DatabaseHelper.STOPS,
      columns: SiriBusStop.dbColumns,
      where: 'geohash in ($placeholders)',
      whereArgs: geohashes,
    );

    final distance = DistanceEquirectangular();
    final stops = results
        .map((row) => SiriBusStop.fromJson(row))
        .where((stop) => distance(location, stop.location) <= maxDistance)
        .toList();
    stops.sort((a, b) => distance(location, a.location)
        .compareTo(distance(location, b.location)));
    cachedNearest = CachedNearestStops(location, maxDistance, stops);
    return stops;
  }

  Future<BusStop?> resolveStop(BusStop template) async {
    final stops =
        await findNearestStops(template.location, count: 3, maxDistance: 100);
    if (stops.isEmpty) return null;
    try {
      return stops.firstWhere((stop) => stop.name == template.name);
    } on StateError {
      // No stop with the given name.
      return null;
    }
  }

  Future<List<BusStop>> findStopsByName(String part,
      {LatLng? around, int max = 3, bool deduplicate = false}) async {
    part = BusStop.normalizeName(part);
    final db = await DatabaseHelper.db.database;
    final results = await db.query(
      DatabaseHelper.STOPS,
      columns: SiriBusStop.dbColumns,
      where: 'norm_name like ?',
      whereArgs: ['%$part%'],
    );
    final stops = [for (var row in results) SiriBusStop.fromJson(row)];

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
      final hasPrefixA = a.normalizedName.split(' ').any((element) => element.startsWith(part));
      final hasPrefixB = b.normalizedName.split(' ').any((element) => element.startsWith(part));
      if (hasPrefixA == hasPrefixB) return 0;
      return hasPrefixA ? -1 : 1;
    });
    return stops.length <= max ? stops : stops.sublist(0, max);
  }

  // Private methods down below /////////////////////////////////////////////

  Future _updateStopsInDatabase(
      {bool force = false, bool fallbackToAsset = false}) async {
    const STOPS_UPDATE_TIMESTAMP = 'stops_update_timestamp';
    final preferences = await SharedPreferences.getInstance();
    final lastDownloadDate = preferences.getInt(STOPS_UPDATE_TIMESTAMP);
    if (lastDownloadDate == null ||
        force ||
        DateTime.fromMillisecondsSinceEpoch(lastDownloadDate)
            .add(Duration(days: 1))
            .isBefore(DateTime.now())) {
      // Stops got old
      List<SiriBusStop> stops;
      try {
        stops = await _downloadStops();
      } on StopsDownloadError catch (e) {
        if (fallbackToAsset) {
          stops = await _loadStopsFromAsset();
        } else
          return;
      }
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

  Future<bool> _needPopulateStops() async {
    final db = await DatabaseHelper.db.database;
    final rowCount = firstIntValue(
        await db.rawQuery("select count(*) from ${DatabaseHelper.STOPS}"));
    return rowCount == null || rowCount < kMinimumStopCount;
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
    if (result.length < kMinimumStopCount)
      throw StopsDownloadError(
          'Got only ${result.length} stops, must be an error.');
    return result;
  }

  Future<List<SiriBusStop>> _loadStopsFromAsset() async {
    final data = await rootBundle.loadString('assets/stops.txt');
    return _parseStopCSV(data);
  }
}
