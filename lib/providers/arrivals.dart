import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_bus/helpers/arrivals_cache.dart';
import 'package:quick_bus/helpers/route_query.dart';
import 'package:quick_bus/helpers/siri.dart';
import 'package:quick_bus/models/arrival.dart';
import 'package:quick_bus/models/bus_stop.dart';

final _arrivalsCache = ArrivalsCache();

final arrivalsProvider = FutureProvider
    .family<List<Arrival>, BusStop?>((ref, stop) async {
  if (stop == null) return [];
  final cached = _arrivalsCache.find(stop);
  if (cached != null) return cached;

  // final stopStr = 'stop ${stop.name}, id=${stop.gtfsId}, siriId=${stop is SiriBusStop ? stop.siriId : '<none>'}';
  // print('Updating arrivals for $stopStr');
  List<Arrival> arrivals = const [];
  try {
    try {
      if (stop is SiriBusStop) arrivals = await SiriHelper().getArrivals(stop);
    } on SiriDownloadError {
      // query OTP, no worries
    }
    if (arrivals.isEmpty) arrivals = await RouteQuery().getArrivals(stop);
  } on SocketException catch (e) {
    // TODO: show dialog, but just one time.
    throw ArrivalFetchError(e.toString());
  } on Exception catch (e) {
    throw ArrivalFetchError(e.toString());
  }
  _arrivalsCache.add(stop, arrivals);
  return arrivals;
});

final multipleArrivalsProvider = FutureProvider.autoDispose
    .family<List<Arrival>, BusStop?>((ref, stop) async {
  if (stop == null) return [];
  List<BusStop> stops = [stop, ...stop.stopsAround];

  List<Arrival> result = [];
  String? errorMessage;
  for (final curStop in stops) {
    try {
      result.addAll(await ref.read(arrivalsProvider(curStop).future));
    } on ArrivalFetchError catch (e) {
      errorMessage = e.message;
    }
  }
  if (result.isEmpty && errorMessage != null)
    throw ArrivalFetchError(errorMessage);
  return result;
});

// Taking a hint from https://github.com/rrousselGit/river_pod/issues/461#issuecomment-825837140
final arrivalsProviderCache =
    StateProvider.autoDispose.family<List<Arrival>, BusStop>((_, stop) => []);

class ArrivalFetchError extends Error {
  final String message;
  ArrivalFetchError(this.message);

  @override
  String toString() => 'ArrivalFetchError: $message';
}
