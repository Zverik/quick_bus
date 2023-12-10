import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class CachedTileProvider extends TileProvider {
  CachedTileProvider();

  @override
  ImageProvider getImage(TileCoordinates coords, TileLayer options) {
    return CachedNetworkImageProvider(
      getTileUrl(coords, options),
      // Maybe replace cacheManager later.
    );
  }
}

TileLayer buildTileLayerOptions() {
  return TileLayer(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    tileProvider: CachedTileProvider(),
  );
}
