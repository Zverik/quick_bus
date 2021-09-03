import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/providers/stop_list.dart';
import 'package:quick_bus/models/bus_stop.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StopMap extends StatefulWidget {
  final LatLng location;
  final bool track;
  final BusStop? chosenStop;
  final void Function(LatLng)? onDrag;
  final void Function(LatLng)? onTrack;

  const StopMap(
      {required this.location,
      this.track = false,
      this.onDrag,
      this.onTrack,
      this.chosenStop});

  @override
  _StopMapState createState() => _StopMapState();
}

class _StopMapState extends State<StopMap> {
  late final MapController mapController;
  late final StreamSubscription<MapEvent> mapSub;
  late final StreamSubscription<Position> locSub;
  LatLng? trackLocation;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    mapSub = mapController.mapEventStream.listen(onMapEvent);
    locSub = Geolocator.getPositionStream(
      intervalDuration: Duration(seconds: 1),
      desiredAccuracy: LocationAccuracy.best,
    ).listen(onLocationEvent);
  }

  void onMapEvent(MapEvent event) {
    if (event is MapEventMove &&
        widget.onDrag != null &&
        event.source != MapEventSource.mapController)
      widget.onDrag!(mapController.center);
  }

  void onLocationEvent(Position pos) {
    var newPos = LatLng(pos.latitude, pos.longitude);
    if (widget.onTrack != null) widget.onTrack!(newPos);
    if (widget.track) {
      mapController.move(newPos, mapController.zoom);
    }
    if (newPos != trackLocation) {
      setState(() {
        trackLocation = newPos;
      });
    }
  }

  @override
  void dispose() {
    mapSub.cancel();
    locSub.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final stopList = context.read(stopsProvider);
    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: widget.location, // This does not work :(
        zoom: 16.0,
        minZoom: 13.0,
        maxZoom: 18.0,
        interactiveFlags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
      ),
      layers: [
        TileLayerOptions(
          urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
          subdomains: ['a', 'b', 'c'],
        ),
        CircleLayerOptions(
          circles: [
            if (trackLocation != null)
              CircleMarker(
                point: trackLocation!,
                color: Colors.blue.withAlpha(150),
                radius: 20.0,
              ),
            for (var stop
                in stopList.findNearestStops(widget.location, count: 10))
              StopWithLabelOptions.getCircleMarker(stop.location),
          ],
        ),
        if (widget.chosenStop != null)
          StopWithLabelOptions(context, widget.chosenStop!),
        if (!widget.track)
          MarkerLayerOptions(
            markers: [
              Marker(
                point: widget.location,
                anchorPos: AnchorPos.exactly(Anchor(15.0, 5.0)),
                builder: (ctx) => Icon(Icons.location_pin),
              ),
            ],
          ),
      ],
    );
  }
}

class StopWithLabelOptions extends GroupLayerOptions {
  final BusStop stop;
  final BuildContext context;
  final bool showLabel;

  StopWithLabelOptions(this.context, this.stop, {this.showLabel = true})
      : super() {
    final chosenStopLabelSize =
        _textSize(context, stop.name, TextStyle(fontSize: 12.0));
    group = [
      if (showLabel)
        MarkerLayerOptions(
          markers: [
            Marker(
              point: stop.location,
              // anchorPos: AnchorPos.align(AnchorAlign.right),
              anchorPos: AnchorPos.exactly(Anchor(
                chosenStopLabelSize.width + 14.0,
                10.0,
              )),
              height: 20.0,
              width: chosenStopLabelSize.width + 24.0,
              builder: (context) => Container(
                padding: const EdgeInsets.only(
                  left: 18.0,
                  right: 2.0,
                  top: 2.5,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(
                    color: Colors.black,
                    width: 1.0,
                  ),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10.0),
                    bottomLeft: Radius.circular(10.0),
                  ),
                ),
                child: Text(
                  stop.name,
                  style: TextStyle(fontSize: 12.0),
                ),
              ),
            )
          ],
        ),
      CircleLayerOptions(
        circles: [getCircleMarker(stop.location)],
      ),
    ];
  }

  // From https://stackoverflow.com/a/62536187
  static Size _textSize(BuildContext context, String text, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
      textScaleFactor: MediaQuery.of(context).textScaleFactor,
    )..layout(minWidth: 0, maxWidth: double.infinity);
    return textPainter.size;
  }

  static getCircleMarker(LatLng location) {
    return CircleMarker(
      point: location,
      color: Colors.yellow,
      borderColor: Colors.black,
      borderStrokeWidth: 1.0,
      radius: 5.0,
    );
  }
}
