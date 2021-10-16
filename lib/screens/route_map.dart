import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:quick_bus/helpers/route_query.dart';
import 'package:quick_bus/helpers/tile_layer.dart';
import 'package:quick_bus/models/arrival.dart';
import 'package:quick_bus/models/bus_stop.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/helpers/equirectangular.dart';
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
  PatternData? route;
  String? errorMessage;
  Path? before;
  Path? after;
  int stopIndex = 0;
  bool showLabels = true;
  final tf = DateFormat.Hm();

  @override
  void initState() {
    super.initState();
    loadRoute();
  }

  void loadRoute() async {
    try {
      route = await RouteQuery().getRouteGeometry(widget.arrival);
      var paths = splitAtStop(route!.geometry, widget.arrival.stop.location);
      before = paths.first;
      after = paths.last;
      stopIndex =
          findStop([for (var s in route!.stops) s.stop], widget.arrival.stop);
    } on Exception catch (e) {
      errorMessage = e.toString();
    }
    setState(() {});
  }

  List<Path?> splitAtStop(Path path, LatLng point) {
    // Always returns a list of two elements: before the stop and after the stop.
    var dist = DistanceEquirectangular();
    LatLng closestPoint = path.coordinates
        .reduce((a, b) => dist(a, point) < dist(b, point) ? a : b);
    int cutIndex = path.coordinates.indexOf(closestPoint);
    return [
      cutIndex == 0
          ? null
          : Path.from(path.coordinates.sublist(0, cutIndex + 1)),
      cutIndex == path.coordinates.length
          ? path
          : Path.from(path.coordinates.sublist(cutIndex)),
    ];
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
        child: Text(AppLocalizations.of(context)!.errorLoadingRoute(errorMessage!)),
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
          bounds:
              LatLngBounds.fromPoints((after ?? route!.geometry).coordinates),
          boundsOptions: FitBoundsOptions(
            padding: const EdgeInsets.all(25.0),
          ),
          minZoom: 10.0,
          maxZoom: 18.0,
          interactiveFlags: InteractiveFlag.all ^ InteractiveFlag.rotate,
        ),
        layers: [
          buildTileLayerOptions(),
          PolylineLayerOptions(
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
            StopWithLabelOptions(context, stop.stop, showLabel: showLabels),
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
