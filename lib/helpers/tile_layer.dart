import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class CachedTileProvider extends TileProvider {
  const CachedTileProvider();

  @override
  ImageProvider getImage(Coords<num> coords, TileLayerOptions options) {
    return CachedNetworkImageProvider(
      getTileUrl(coords, options),
      // Maybe replace cacheManager later.
    );
  }
}

TileLayerOptions buildTileLayerOptions([bool showAttribution = false]) {
  return TileLayerOptions(
    urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    tileProvider: const CachedTileProvider(),
    attributionBuilder: !showAttribution
        ? null
        : (context) => Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text('© OpenStreetMap contributors'),
            ),
  );
}
