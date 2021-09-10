import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_bus/helpers/arrivals_cache.dart';
import 'package:quick_bus/helpers/route_query.dart';
import 'package:quick_bus/helpers/siri.dart';
import 'package:quick_bus/models/arrival.dart';
import 'package:quick_bus/models/bus_stop.dart';

final _arrivalsCache = ArrivalsCache();

final arrivalsProvider = FutureProvider.autoDispose.family<List<Arrival>, BusStop?>((ref, stop) async {
  if (stop == null) return [];
  final cached = _arrivalsCache.find(stop);
  if (cached != null) return cached;

  final stopStr = 'stop ${stop.name}, id=${stop.gtfsId}, siriId=${stop is SiriBusStop ? stop.siriId : '<none>'}';
  print('Updating arrivals for $stopStr');
  List<Arrival> arrivals = const [];
  try {
    if (stop is SiriBusStop)
      arrivals = await SiriHelper().getArrivals(stop);
    if (arrivals.isEmpty)
      arrivals = await RouteQuery().getArrivals(stop);
  } on SocketException catch (e) {
    // TODO: show dialog, but just one time.
    throw ArrivalFetchError(e.toString());
  } on Exception catch (e) {
    throw ArrivalFetchError(e.toString());
  }
  _arrivalsCache.add(stop, arrivals);
  return arrivals;
});

class ArrivalFetchError extends Error {
  final String message;
  ArrivalFetchError(this.message);

  @override
  String toString() => 'ArrivalFetchError: $message';
}