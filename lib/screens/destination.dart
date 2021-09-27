import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/providers/last_dest.dart';
import 'package:quick_bus/screens/find_route.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_bus/screens/search.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class DestinationPage extends StatefulWidget {
  final LatLng start;
  final LatLng? destination;

  const DestinationPage({required this.start, this.destination});

  @override
  _DestinationPageState createState() => _DestinationPageState();
}

class _DestinationPageState extends State<DestinationPage> {
  MapController mapController = MapController();
  late LatLng center;

  @override
  void initState() {
    super.initState();
    center = widget.destination ?? widget.start;
    mapController.mapEventStream.listen((event) {
      if (event is MapEventMove) {
        setState(() {
          center = mapController.center;
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
          center: center,
          zoom: 13.0,
          minZoom: 11.0,
          maxZoom: 17.0,
          interactiveFlags: InteractiveFlag.all ^ (InteractiveFlag.rotate),
        ),
        layers: [
          TileLayerOptions(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: ['a', 'b', 'c'],
          ),
          MarkerLayerOptions(
            markers: [
              Marker(
                point: center,
                anchorPos: AnchorPos.exactly(Anchor(15.0, 5.0)),
                builder: (ctx) => Icon(Icons.location_pin),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.arrow_forward),
        onPressed: () {
          final destination = mapController.center;
          context.read(lastDestinationsProvider.notifier).add(destination);
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
