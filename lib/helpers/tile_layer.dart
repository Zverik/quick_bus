import 'package:flutter_map/flutter_map.dart';

TileLayer buildTileLayerOptions() {
  return TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    tileProvider: NetworkTileProvider(
      cachingProvider: BuiltInMapCachingProvider.getOrCreateInstance(maxCacheSize: 10_000_000),
    ),
    userAgentPackageName: 'info.zverev.ilya.quick_bus',
  );
}
