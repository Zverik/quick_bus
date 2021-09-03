import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quick_bus/helpers/route_query.dart';
import 'package:quick_bus/providers/bookmarks.dart';
import 'package:quick_bus/providers/saved_plan.dart';
import 'package:quick_bus/models/bus_stop.dart';
import 'package:quick_bus/constants.dart';
import 'package:quick_bus/helpers/siri.dart';
import 'package:quick_bus/providers/stop_list.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/screens/itinerary.dart';
import 'package:quick_bus/widgets/stop_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_bus/widgets/bookmark_row.dart';
import 'package:quick_bus/widgets/arrivals.dart';

class MonitorPage extends StatefulWidget {
  final LatLng? location;
  MonitorPage({this.location});

  @override
  _MonitorPageState createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  BusStop? nearestStop;
  late LatLng location;
  bool tracking = true;
  LatLng? lastTrack;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    location = widget.location ?? kDefaultLocation.toLatLng();
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      updateArrivals();
    });

    // Otherwise the context does not allow inheritance
    // See https://stackoverflow.com/q/49457717
    WidgetsBinding.instance!.addPostFrameCallback((_) {
      updateNearestStops(context);
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> updateArrivals([BusStop? stop]) async {
    if (stop == null) stop = nearestStop;
    if (stop != null) {
      stop.arrivals = [];
      try {
        await SiriHelper().updateArrivals([stop]);
        if (stop.arrivals.isEmpty) {
          await RouteQuery().updateArrivals(stop);
        }
        setState(() {});
      } on Exception {
        // nothing
      }
    }
  }

  void updateNearestStops(BuildContext context) {
    final stopList = context.read(stopsProvider);
    List<BusStop> newStops = stopList.findNearestStops(location, count: 1);
    var nextStop = newStops.isEmpty ? null : newStops.first;
    if (nextStop == nearestStop) return;

    setState(() {
      nearestStop = nextStop;
      updateArrivals(nextStop);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kAppTitle),
        actions: [
          Consumer(
            builder: (context, watch, child) {
              final plan = watch(savedPlanProvider);
              if (!plan.isActive)
                return Container();
              else
                return IconButton(
                    icon: Icon(Icons.bookmark),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) =>
                                ItineraryPage(plan.itinerary)),
                      );
                    });
            },
          ),
          IconButton(
            onPressed: tracking
                ? null
                : () {
                    setState(() {
                      tracking = true;
                      if (lastTrack != null) location = lastTrack!;
                    });
                    updateNearestStops(context);
                  },
            icon: const Icon(Icons.my_location),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StopMap(
              location: location,
              track: tracking,
              chosenStop: nearestStop,
              onDrag: (pos) {
                setState(() {
                  tracking = false;
                  location = pos;
                });
                updateNearestStops(context);
              },
              onTrack: (pos) {
                lastTrack = pos;
                if (tracking) {
                  setState(() {
                    location = pos;
                  });
                  updateNearestStops(context);
                }
              },
            ),
          ),
          Consumer(
            builder: (context, watch, child) {
              final bookmarks = watch(bookmarkProvider);
              return BookmarkRow(location, bookmarks);
            },
          ),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => updateArrivals(),
              child: ArrivalsList(stop: nearestStop),
            ),
          ),
        ],
      ),
    );
  }
}