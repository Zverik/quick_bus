import 'package:flutter/material.dart';
import 'package:quick_bus/models/route_element.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:quick_bus/helpers/siri.dart';
import 'package:quick_bus/providers/stop_list.dart';
import 'package:quick_bus/models/arrival.dart';
import 'package:quick_bus/models/bus_stop.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:quick_bus/widgets/arrival_row.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:quick_bus/helpers/rich_tags.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ItineraryLeg extends StatefulWidget {
  final RouteElement leg;
  final bool isPortrait;

  ItineraryLeg(this.leg, {Orientation? orientation})
      : isPortrait = orientation == null || orientation == Orientation.portrait;

  @override
  _ItineraryLegState createState() => _ItineraryLegState();
}

class _ItineraryLegState extends State<ItineraryLeg> {
  static final tf = DateFormat.Hm();
  Arrival? arrival;
  late List<TextSpan> description;
  late Color pathColor;
  bool pathDotted = false;
  late LatLngBounds mapBounds;
  bool arrivalUpdated = false;

  prepareMessages(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    mapBounds = LatLngBounds.fromPoints(widget.leg.path.coordinates);
    final destination = widget.leg.endName == 'Destination'
        ? loc.walkDestination
        : widget.leg.endName;
    if (widget.leg is TransitRouteElement) {
      TransitRouteElement element = widget.leg as TransitRouteElement;
      pathColor = element.route.mode.isRailBased ? Colors.red : Colors.blue;
      if (!arrivalUpdated) {
        arrival = Arrival(
          route: element.route,
          scheduled: element.departure,
          stop: BusStop(
            gtfsId: '',
            location: element.path.first,
            name: element.startName,
          ),
        );
        // So that we have a fully working context.
        Future.delayed(Duration.zero, () {
          updateArrival(context);
          arrivalUpdated = true;
        });
      }
      if (element.stopCount > 3 && element.intermediateStops.length > 2) {
        mapBounds = LatLngBounds.fromPoints([
          ...element.intermediateStops
              .sublist(element.intermediateStops.length - 2)
              .map((e) => e.stop.location),
          element.path.last,
        ]);
      }
      if (element.stopCount <= 3) {
        description = parseTaggedText(
            loc.rideStops(loc.stops(element.stopCount), destination));
      } else {
        description =
            parseTaggedText(loc.rideTime(element.arrival, destination));
      }
    } else {
      pathColor = Colors.black;
      pathDotted = true;
      final walkDistance = (widget.leg.distanceMeters / 100).round() * 100;
      description = parseTaggedText(loc.walkMeters(walkDistance, destination));
    }
  }

  updateArrival(BuildContext context) async {
    const MAX_SCHEDULE_DRIFT = Duration(minutes: 2);
    final arrival = this.arrival; // Make a copy to avoid null errors
    if (arrival == null) return;
    final stopList = context.read(stopsProvider);
    final stop = await stopList.resolveStop(arrival.stop);
    if (stop != null) {
      final arrivals = await SiriHelper().getArrivals(stop);
      var properRoute =
          arrivals.where((element) => element.route == arrival.route);
      if (properRoute.isEmpty) return;
      var relevantArrivals = properRoute.where((element) =>
          element.scheduled.difference(arrival.scheduled).abs() <=
          MAX_SCHEDULE_DRIFT);
      if (relevantArrivals.isEmpty) return;
      if (relevantArrivals.length > 1) {
        final arrivalsList = relevantArrivals.toList();
        arrivalsList.sort((a, b) => a.scheduled
            .difference(arrival.scheduled)
            .abs()
            .compareTo(b.scheduled.difference(arrival.scheduled).abs()));
        relevantArrivals = arrivalsList;
      }
      setState(() {
        print('Found arrival for ${arrival.route.number} @ ${stop.name}, '
            '${tf.format(arrival.expected)} => ${tf.format(relevantArrivals.first.expected)}');
        this.arrival = relevantArrivals.first;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    prepareMessages(context);
    final descPart =
        Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      if (arrival != null)
        Padding(
          padding: const EdgeInsets.only(top: 10.0),
          child: ArrivalRow(arrival!, forceExactTime: true),
        ),
      Padding(
        padding: EdgeInsets.only(
          bottom: 10.0,
          left: 15.0,
          right: 10.0,
          top: arrival != null ? 5.0 : 10.0,
        ),
        child: RichText(
            text: TextSpan(
                style: DefaultTextStyle.of(context).style.copyWith(
                      fontSize: 20.0,
                    ),
                children: description)),
      )
    ]);
    final map = SizedBox(
      height: 200.0,
      child: FlutterMap(
          options: MapOptions(
            bounds: mapBounds,
            boundsOptions: FitBoundsOptions(
              padding: const EdgeInsets.all(25.0),
            ),
            minZoom: 10.0,
            maxZoom: 18.0,
            interactiveFlags:
                InteractiveFlag.pinchZoom | InteractiveFlag.pinchMove,
          ),
          layers: [
            TileLayerOptions(
              urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
              subdomains: ['a', 'b', 'c'],
            ),
            PolylineLayerOptions(polylines: [
              Polyline(
                points: widget.leg.path.coordinates,
                color: pathColor.withOpacity(0.7),
                strokeWidth: 7.0,
                isDotted: pathDotted,
              )
            ]),
            if (widget.leg is TransitRouteElement)
              CircleLayerOptions(circles: [
                for (var stop
                    in (widget.leg as TransitRouteElement).intermediateStops)
                  CircleMarker(
                    point: stop.stop.location,
                    color: Colors.transparent,
                    borderColor: Colors.black,
                    borderStrokeWidth: 1.0,
                    radius: 3.0,
                  )
              ]),
            CircleLayerOptions(circles: [
              CircleMarker(
                point: widget.leg.path.last,
                color: Colors.yellow,
                borderColor: Colors.black,
                borderStrokeWidth: 1.0,
                radius: 5.0,
              )
            ]),
          ]),
    );
    if (widget.isPortrait) {
      return Column(
        children: [descPart, map],
      );
    } else {
      // landscape
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [Expanded(child: descPart), Expanded(child: map)],
      );
    }
  }
}
