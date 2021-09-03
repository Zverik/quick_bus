import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:osm_nominatim/osm_nominatim.dart';
import 'package:quick_bus/helpers/database.dart';
import 'package:quick_bus/constants.dart';

final lastDestinationsProvider =
    StateNotifierProvider<LastDestinations, List<StoredDestination>>(
        (_) => LastDestinations());

class StoredDestination {
  final LatLng destination;
  String name;
  DateTime accessedOn;
  DateTime createdOn;

  StoredDestination(this.destination, {String? name, DateTime? accessedOn})
      : this.name = name ?? "${destination.round(decimals: 5)}",
        this.accessedOn = accessedOn ?? DateTime.now(),
        createdOn = DateTime.now();

  factory StoredDestination.fromJson(Map<String, dynamic> json) {
    return StoredDestination(
      LatLng(json['lat'], json['lon']),
      name: json['name'],
      accessedOn: DateTime.fromMillisecondsSinceEpoch(json['last_used']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'lat': destination.latitude,
      'lon': destination.longitude,
      'name': name,
      'last_used': accessedOn.millisecondsSinceEpoch,
    };
  }

  bool get isRecent =>
      createdOn.add(Duration(minutes: 3)).isAfter(DateTime.now());
}

class LastDestinations extends StateNotifier<List<StoredDestination>> {
  LastDestinations() : super([]) {
    _loadDestinations();
  }

  add(LatLng destination, [String? name]) {
    final dest = StoredDestination(destination, name: name);
    if (state.any((element) => element.destination == destination)) return;
    var newList = [dest, ...state];
    if (newList.length > kMaxLatestDestinations) {
      newList = newList.sublist(0, kMaxLatestDestinations);
      _saveDestinations();
    } else {
      _addDestination(dest);
    }
    state = newList;
    findName(dest);
  }

  used(StoredDestination dest) {
    dest.accessedOn = DateTime.now();
    _updateDestination(dest);
    var newList = state.toList();
    newList.sort((a, b) => a.accessedOn.compareTo(b.accessedOn));
    if (!listEquals(newList, state)) state = newList;
  }

  findName(StoredDestination dest) async {
    var result = await Nominatim.reverseSearch(
      lat: dest.destination.latitude,
      lon: dest.destination.longitude,
      addressDetails: true,
      zoom: 18,
    );
    dest.name = result.displayName;
    state = state;
  }

  _loadDestinations() async {
    final db = await DatabaseHelper.db.database;
    final results = await db.query(
      DatabaseHelper.DESTINATIONS,
      columns: ['lat', 'lon', 'name', 'last_used'],
    );
    state = [for (var d in results) StoredDestination.fromJson(d)];
  }

  _addDestination(StoredDestination dest) async {
    final db = await DatabaseHelper.db.database;
    await db.insert(DatabaseHelper.DESTINATIONS, dest.toJson());
  }

  _updateDestination(StoredDestination dest) async {
    final db = await DatabaseHelper.db.database;
    await db.update(
      DatabaseHelper.DESTINATIONS,
      dest.toJson(),
      where: 'name = ?',
      whereArgs: [dest.name],
    );
  }

  _saveDestinations() async {
    final db = await DatabaseHelper.db.database;
    await db.transaction((txn) async {
      await txn.delete(DatabaseHelper.DESTINATIONS);
      for (var q in state)
        await txn.insert(DatabaseHelper.DESTINATIONS, q.toJson());
    });
  }
}
