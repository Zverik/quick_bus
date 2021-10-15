import 'package:quick_bus/models/arrival.dart';
import 'package:quick_bus/models/bus_stop.dart';
import 'package:quick_bus/constants.dart';

class ArrivalsCacheItem {
  List<Arrival> arrivals;
  DateTime cachedOn;

  ArrivalsCacheItem(this.arrivals) : cachedOn = DateTime.now();
  bool get isOld => cachedOn.add(kCacheArrivals).isBefore(DateTime.now());
}

class ArrivalsCache {
  Map<String, ArrivalsCacheItem> _cache = {};

  add(BusStop stop, List<Arrival> arrivals) {
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