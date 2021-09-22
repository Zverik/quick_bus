import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';

// TODO!

final locationProvider = StreamProvider.autoDispose<LatLng>((ref) {
  return Stream.value(LatLng(0.0, 0.0));
});