import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:quick_bus/helpers/bus_locations.dart';
import 'package:quick_bus/helpers/route_query.dart';
import 'package:quick_bus/helpers/tile_layer.dart';
import 'package:quick_bus/models/arrival.dart';
import 'package:quick_bus/models/bus_stop.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/helpers/equirectangular.dart';
import 'package:quick_bus/helpers/path_utils.dart';
import 'package:quick_bus/widgets/stop_map.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter_gen/gen_l10n/l10n.dart';

class RoutePage extends StatefulWidget {
  final Arrival arrival;

  const RoutePage(this.arrival);

  @override
  _RoutePageState createState() => _RoutePageState();
}

class _RoutePageState extends State<RoutePage> {
  static const kBusMarkerSize = 16.0;
  PatternData? route;
  String? errorMessage;
  Path? before;
  Path? after;
  int stopIndex = 0;
  bool showLabels = true;
  final tf = DateFormat.Hm();
  late Timer locationsTimer;
  List<BusLocation> locations = const [];

  @override
  void initState() {
    super.initState();
    loadRoute().then((_) => updateLocations());
    locationsTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      updateLocations();
    });
  }

  @override
  void dispose() {
    locationsTimer.cancel();
    super.dispose();
  }

  Future loadRoute() async {
    try {
      route = await RouteQuery().getRouteGeometry(widget.arrival);
      var paths =
          PathUtils().splitAt(route!.geometry, widget.arrival.stop.location);
      before = paths.first;
      after = paths.last;
      stopIndex =
          findStop([for (var s in route!.stops) s.stop], widget.arrival.stop);
    } on Exception catch (e) {
      errorMessage = e.toString();
    }
    setState(() {});
  }

  updateLocations() async {
    var newLoc = await BusLocations().getLocations(widget.arrival.route);
    if (before != null && PathUtils().fastLength(before!) > 300) {
      // Filter by proximity to "before" path
      final helper = PathUtils();
      newLoc = newLoc
          .where((element) => helper.distance(element.location, before!) < 200)
          .toList();
    }
    if (mounted) {
      setState(() {
        locations = newLoc;
      });
    }
  }

  int findStop(List<BusStop> stops, BusStop stop) {
    var dist = DistanceEquirectangular();
    BusStop closestStop = stops.reduce((a, b) =>
        dist(a.location, stop.location) < dist(b.location, stop.location)
            ? a
            : b);
    return stops.indexOf(closestStop);
  }

  @override
  Widget build(BuildContext context) {
    Widget body;
    if (errorMessage != null) {
      body = Center(
        child: Text(
            AppLocalizations.of(context)!.errorLoadingRoute(errorMessage!)),
      );
    } else if (route == null) {
      body = Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(width: double.infinity),
          CircularProgressIndicator(value: null),
          SizedBox(height: 20.0),
          Text(
            AppLocalizations.of(context)!.loadingRoute,
            style: TextStyle(
              fontSize: 20.0,
            ),
          ),
        ],
      );
    } else {
      body = FlutterMap(
        options: MapOptions(
          initialCenter: widget.arrival.stop.location,
          initialZoom: 13.0,
          minZoom: 10.0,
          maxZoom: 18.0,
          interactionOptions: InteractionOptions(
              flags: InteractiveFlag.all ^ (InteractiveFlag.rotate)),
        ),
        children: [
          buildTileLayerOptions(),
          PolylineLayer(
            polylines: [
              if (before != null)
                Polyline(
                  points: before!.coordinates,
                  color: Colors.blue.shade400.withOpacity(0.4),
                  strokeWidth: 3.0,
                ),
              if (after != null)
                Polyline(
                  points: after!.coordinates,
                  color: Colors.blue.shade800.withOpacity(0.9),
                  strokeWidth: 3.0,
                ),
            ],
          ),
          for (var stop in route!.stops.sublist(stopIndex))
            // When we get times: copyWithName('${stop.stop.name} ${tf.format(stop.expected)}')
            StopWithLabel(stop.stop, showLabel: showLabels),
          MarkerLayer(markers: [
            for (var location in locations)
              Marker(
                point: location.location,
                alignment: Alignment.center,
                height: kBusMarkerSize,
                width: kBusMarkerSize,
                child: Transform.rotate(
                  angle: 3.1415925 / 180 * (location.direction + 45),
                  child: Container(
                    decoration: BoxDecoration(
                      color: location.route.mode.color,
                      border: Border.all(
                        color: Colors.black,
                        width: 1.0,
                      ),
                      borderRadius: BorderRadius.only(
                        topRight: Radius.circular(kBusMarkerSize / 2),
                        bottomRight: Radius.circular(kBusMarkerSize / 2),
                        bottomLeft: Radius.circular(kBusMarkerSize / 2),
                      ),
                    ),
                    child: Transform.rotate(
                      angle: 3.14159 / 180 * 45,
                      child: Icon(
                        Icons.arrow_back,
                        size: kBusMarkerSize / 2,
                      ),
                    ),
                  ),
                ),
              ),
          ]),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
            '${widget.arrival.route.mode.localizedName(context)} ${widget.arrival.route.number}'),
        actions: [
          if (route != null)
            IconButton(
              onPressed: () {
                setState(() {
                  showLabels = !showLabels;
                });
              },
              icon: Icon(
                  showLabels ? Icons.label_off_outlined : Icons.label_outline),
              tooltip: AppLocalizations.of(context)?.showStopNames,
            ),
        ],
      ),
      body: body,
    );
  }
}
