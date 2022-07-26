import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/helpers/equirectangular.dart';
import 'package:quick_bus/helpers/tile_layer.dart';
import 'package:quick_bus/providers/geolocation.dart';
import 'package:quick_bus/providers/stop_list.dart';
import 'package:quick_bus/models/bus_stop.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class StopMapController {
  Function(LatLng, bool)? listener;

  setLocation(LatLng location, {bool emitDrag = true}) {
    if (listener != null) listener!(location, emitDrag);
  }
}

class StopMap extends ConsumerStatefulWidget {
  final LatLng location;
  final BusStop? chosenStop;
  final void Function(LatLng)? onDrag;
  final void Function(LatLng)? onDragEnd;
  final void Function(LatLng)? onTrack;
  final StopMapController? controller;

  const StopMap(
      {required this.location,
      this.onDrag,
      this.onDragEnd,
      this.onTrack,
      this.chosenStop,
      this.controller});

  @override
  _StopMapState createState() => _StopMapState();
}

class _StopMapState extends ConsumerState<StopMap> {
  late final MapController mapController;
  late final StreamSubscription<MapEvent> mapSub;
  List<LatLng> nearestStops = [];
  LatLng? lastNearestStopCheck;
  static const kNearestStopUpdateThreshold = 100.0; // meters
  bool showAttribution = true;

  @override
  void initState() {
    super.initState();
    mapController = MapController();
    if (widget.controller != null)
      widget.controller!.listener = onControllerLocation;
    mapSub = mapController.mapEventStream.listen(onMapEvent);
    Future.delayed(Duration(milliseconds: 500), () {
      updateNearestStops();
    });
    Future.delayed(Duration(seconds: 9), () {
      if (showAttribution) {
        setState(() {
          showAttribution = false;
        });
      }
    });
  }

  void onMapEvent(MapEvent event) {
    if (event is MapEventMove) {
      updateNearestStops(event.targetCenter);
      if (event.source != MapEventSource.mapController) {
        ref.read(trackingProvider.state).state = false;
        if (widget.onDrag != null) widget.onDrag!(event.targetCenter);
      }
    } else if (event is MapEventMoveEnd) {
      if (widget.onDragEnd != null &&
          event.source != MapEventSource.mapController)
        widget.onDragEnd!(event.center);
    }
  }

  void onControllerLocation(LatLng location, bool emitDrag) {
    mapController.move(location, mapController.zoom);
    if (emitDrag && widget.onDrag != null) widget.onDrag!(location);
  }

  @override
  void dispose() {
    mapSub.cancel();
    super.dispose();
  }

  updateNearestStops([LatLng? around]) {
    if (around == null) around = widget.location;
    final distance = DistanceEquirectangular();
    if (lastNearestStopCheck != null &&
        distance(lastNearestStopCheck!, around) < kNearestStopUpdateThreshold)
      return;
    lastNearestStopCheck = around;

    final stopList = ref.read(stopsProvider);
    stopList
        .findNearestStops(around, count: 10, maxDistance: 1000)
        .then((stops) {
      setState(() {
        nearestStops =
            stops.map((stop) => stop.location).toList(growable: false);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final LatLng? trackLocation = ref.watch(geolocationProvider);

    // When tracking location, move map and notify the poi list.
    ref.listen<LatLng?>(geolocationProvider, (_, LatLng? location) {
      if (location != null && ref.watch(trackingProvider)) {
        mapController.move(location, mapController.zoom);
        if (widget.onDragEnd != null) widget.onDragEnd!(location);
        if (widget.onTrack != null) widget.onTrack!(location);
      }
    });

    // When turning the tracking on, move the map immediately.
    ref.listen(trackingProvider, (_, bool newState) {
      if (trackLocation != null && newState) {
        mapController.move(trackLocation, mapController.zoom);
        if (widget.onDragEnd != null) widget.onDragEnd!(trackLocation);
        if (widget.onTrack != null) widget.onTrack!(trackLocation);
      }
    });

    return FlutterMap(
      mapController: mapController,
      options: MapOptions(
        center: widget.location, // This does not work :(
        zoom: 16.0,
        minZoom: 13.0,
        maxZoom: 18.0,
        interactiveFlags: InteractiveFlag.drag | InteractiveFlag.pinchZoom,
      ),
      nonRotatedChildren: [
        if (showAttribution)
          AttributionWidget(
            attributionBuilder: (context) => Padding(
              padding: const EdgeInsets.all(4.0),
              child: Text('© OpenStreetMap contributors'),
            ),
          ),
      ],
      layers: [
        buildTileLayerOptions(),
        CircleLayerOptions(
          circles: [
            if (trackLocation != null)
              CircleMarker(
                point: trackLocation,
                color: Colors.blue.withOpacity(0.6),
                radius: 15.0,
              ),
            for (var stop in nearestStops)
              StopWithLabelOptions.getCircleMarker(stop),
          ],
        ),
        if (widget.chosenStop != null)
          StopWithLabelOptions(context, widget.chosenStop!),
        if (!ref.watch(trackingProvider))
          MarkerLayerOptions(
            markers: [
              Marker(
                point: widget.location,
                anchorPos: AnchorPos.exactly(
                    Anchor(15.0, trackLocation == null ? 5.0 : 12.0)),
                builder: (ctx) => Icon(
                  trackLocation == null ? Icons.location_pin : Icons.adjust,
                  color: trackLocation == null
                      ? Colors.black
                      : Colors.black.withOpacity(0.3),
                  size: 24.0,
                ),
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
