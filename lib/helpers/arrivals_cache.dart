import 'package:quick_bus/models/arrival.dart';
import 'package:quick_bus/models/bus_stop.dart';

class ArrivalsCacheItem {
  List<Arrival> arrivals;
  DateTime cachedOn;

  ArrivalsCacheItem(this.arrivals) : cachedOn = DateTime.now();
  bool get isOld => cachedOn.add(Duration(seconds: 10)).isBefore(DateTime.now());
}

class ArrivalsCache {
  Map<String, ArrivalsCacheItem> _cache = {};

  add(BusStop stop, List<Arrival> arrivals) {
    // if (arrivals.isEmpty) return;
    _cache[stop.gtfsId] = ArrivalsCacheItem(arrivals);
  }

  List<Arrival>? find(BusStop stop) {
    final item = _cache[stop.gtfsId];
    if (item == null) return null;
    if (item.isOld) {
      _cache.remove(stop.gtfsId);
      return null;
    }
    return item.arrivals;
  }
}