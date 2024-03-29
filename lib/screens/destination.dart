import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/helpers/tile_layer.dart';
import 'package:quick_bus/providers/last_dest.dart';
import 'package:quick_bus/screens/find_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class DestinationPage extends ConsumerStatefulWidget {
  final LatLng start;
  final LatLng? destination;
  final bool zoomCloser;

  const DestinationPage(
      {required this.start, this.destination, this.zoomCloser = false});

  @override
  _DestinationPageState createState() => _DestinationPageState();
}

class _DestinationPageState extends ConsumerState<DestinationPage> {
  MapController mapController = MapController();
  late LatLng center;

  @override
  void initState() {
    super.initState();
    center = widget.destination ?? widget.start;
    mapController.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        setState(() {
          center = mapController.camera.center;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)?.whereTo ?? 'Where to?'),
        actions: [
          IconButton(
            onPressed: () async {
              final pos = await Geolocator.getLastKnownPosition();
              if (pos != null) {
                final newPos = LatLng(pos.latitude, pos.longitude);
                mapController.move(newPos, mapController.zoom);
              }
            },
            icon: const Icon(Icons.my_location),
            tooltip: AppLocalizations.of(context)?.myLocation,
          ),
        ],
      ),
      body: FlutterMap(
        mapController: mapController,
        options: MapOptions(
          initialCenter: center,
          initialZoom: widget.zoomCloser ? 15.0 : 13.0,
          minZoom: 11.0,
          maxZoom: 17.0,
          interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all ^ (InteractiveFlag.rotate)),
          onTap: (tapPos, latlng) {
            final zoom = mapController.camera.zoom;
            mapController.move(latlng, zoom >= 17 ? zoom : zoom + 2);
          },
        ),
        children: [
          buildTileLayerOptions(),
          MarkerLayer(
            markers: [
              Marker(
                point: center,
                alignment: Alignment(0.0, -0.7),
                child: Icon(Icons.location_pin),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        onPressed: () {
          final destination = mapController.center;
          ref.read(lastDestinationsProvider.notifier).add(destination);
          Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (context) => FindRoutePage(
                  start: widget.start,
                  end: destination,
                ),
              ));
        },
      ),
    );
  }
}
