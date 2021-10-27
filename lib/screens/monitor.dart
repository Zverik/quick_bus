import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/constants.dart';
import 'package:quick_bus/helpers/arrivals_cache.dart';
import 'package:quick_bus/models/arrival.dart';
import 'package:quick_bus/models/bookmark.dart';
import 'package:quick_bus/models/bus_stop.dart';
import 'package:quick_bus/providers/arrivals.dart';
import 'package:quick_bus/providers/bookmarks.dart';
import 'package:quick_bus/providers/saved_plan.dart';
import 'package:quick_bus/providers/stop_list.dart';
import 'package:quick_bus/providers/tutorial_state.dart';
import 'package:quick_bus/screens/itinerary.dart';
import 'package:quick_bus/screens/tutorial.dart';
import 'package:quick_bus/widgets/arrivals.dart';
import 'package:quick_bus/widgets/bookmark_row.dart';
import 'package:quick_bus/widgets/stop_map.dart';

class MonitorPage extends StatefulWidget {
  final LatLng? location;
  MonitorPage({this.location});

  @override
  _MonitorPageState createState() => _MonitorPageState();
}

class _MonitorPageState extends State<MonitorPage> {
  BusStop? nearestStop; // Stop nearest to map center
  BusStop?
      arrivalsStop; // Updated to nearestStop when needed to redraw arrivals
  List<Arrival> arrivals = []; // Arrivals for the nearest stop
  late LatLng location; // Map center location
  bool tracking = true; // Are we following GPS signal?
  LatLng? lastTrack; // Last GPS location, even when not tracking
  Timer? nearestStopTimer; // We update nearest stop with a slight delay
  LatLng?
      locationToUpdateForNearest; // And save the last location to find nearest stops for it
  late Timer _timer; // To update arrivals twice a minute
  BusStop?
      lastArrivalsStop; // In case nearest stop is quickly updated, here's the next one
  bool lookingUpArrivals = false; // Whether we display spinner or an empty list
  String?
      arrivalsUpdateError; // Error message for when arrivals querying failed
  final arrivalsCache = ArrivalsCache(); // To solve issues with arrivals
  bool draggingBookmark = false; // Are we dragging a bookmark?
  final stopMapController =
      StopMapController(); // To force location change on the map

  @override
  void initState() {
    super.initState();
    location =
        widget.location ?? LatLng(kDefaultLocation[0], kDefaultLocation[1]);
    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      context.refresh(arrivalsProvider(nearestStop));
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

  forceUpdateNearestStops(
      BuildContext context, LatLng location, bool shouldUpdateArrivals) async {
    if (nearestStopTimer != null) {
      nearestStopTimer!.cancel();
      nearestStopTimer = null;
    }
    ;
    final stopList = context.read(stopsProvider);
    List<BusStop> newStops =
        await stopList.findNearestStops(location, count: 1, maxDistance: 200);
    var nextStop = newStops.isEmpty ? null : newStops.first;
    if (nextStop == nearestStop &&
        (!shouldUpdateArrivals || arrivalsStop == nextStop)) return;

    setState(() {
      nearestStop = nextStop;
      if (shouldUpdateArrivals) arrivalsStop = nextStop;
    });
  }

  updateNearestStops(BuildContext context, {bool shouldUpdateArrivals = true}) {
    locationToUpdateForNearest = location;
    if (nearestStopTimer != null) return;
    nearestStopTimer = Timer(Duration(milliseconds: 300), () async {
      nearestStopTimer = null;
      forceUpdateNearestStops(
          context, locationToUpdateForNearest!, shouldUpdateArrivals);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kAppTitle),
        actions: [
          Consumer(builder: (context, watch, child) {
            final seenTutorial = watch(seenTutorialProvider);
            if (seenTutorial)
              return Container();
            else
              return IconButton(
                icon: Icon(Icons.help),
                tooltip: AppLocalizations.of(context)!.openTutorial,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => TutorialPage()),
                  );
                },
              );
          }),
          Consumer(
            builder: (context, watch, child) {
              final plan = watch(savedPlanProvider);
              if (!plan.isActive)
                return Container();
              else
                return IconButton(
                    icon: Icon(Icons.bookmark),
                    tooltip: AppLocalizations.of(context)?.restorePlan,
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
                    stopMapController.setLocation(lastTrack!, emitDrag: false);
                    forceUpdateNearestStops(context, lastTrack!, true);
                  },
            icon: const Icon(Icons.my_location),
            tooltip: AppLocalizations.of(context)?.myLocation,
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (BuildContext context, Orientation orientation) {
          final children = <Widget>[
            Expanded(
              child: Stack(
                children: [
                  StopMap(
                    location: location,
                    track: tracking,
                    chosenStop: nearestStop,
                    controller: stopMapController,
                    onDrag: (pos) {
                      setState(() {
                        tracking = false;
                        location = pos;
                      });
                      updateNearestStops(context, shouldUpdateArrivals: false);
                    },
                    onDragEnd: (pos) {
                      forceUpdateNearestStops(context, pos, true);
                    },
                    onTrack: (pos) {
                      lastTrack = pos;
                      if (tracking) {
                        setState(() {
                          location = pos;
                        });
                        forceUpdateNearestStops(context, pos, true);
                      }
                    },
                  ),
                  if (draggingBookmark)
                    DragTarget<Bookmark>(
                      builder: (context, cData, rData) => Container(
                        color: Colors.white.withOpacity(0.7),
                        child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.bookmarkTarget,
                            style: TextStyle(
                              fontSize: 30.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade800,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                      onAccept: (bookmark) {
                        stopMapController.setLocation(bookmark.location);
                      },
                    ),
                ],
              ),
            ),
            Consumer(
              builder: (context, watch, child) {
                final bookmarks = watch(bookmarkProvider);
                return BookmarkRow(
                  location,
                  bookmarks,
                  trackLocation: lastTrack,
                  orientation: orientation,
                  onStartDrag: () {
                    setState(() {
                      draggingBookmark = true;
                    });
                  },
                  onEndDrag: () {
                    setState(() {
                      draggingBookmark = false;
                    });
                  },
                );
              },
            ),
            Expanded(
                child: arrivalsStop == null
                    ? Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Center(
                          child: Text(
                            AppLocalizations.of(context)!.noStopsNearby,
                            style: kArrivalsMessageStyle,
                            textAlign: TextAlign.center,
                          ),
                        ),
                    )
                    : ArrivalsListContainer(arrivalsStop!)),
          ];

          return Flex(
            direction: orientation == Orientation.portrait
                ? Axis.vertical
                : Axis.horizontal,
            children: children,
          );
        },
      ),
    );
  }
}

class ArrivalsListContainer extends StatelessWidget {
  final BusStop arrivalsStop;

  ArrivalsListContainer(this.arrivalsStop);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () => context.refresh(arrivalsProvider(arrivalsStop)),
      child: Consumer(
        builder: (context, watch, child) {
          final arrivalsValue = watch(arrivalsProvider(arrivalsStop));
          return arrivalsValue.when(
            data: (data) => data.isEmpty
                ? Center(
                    child: Text(AppLocalizations.of(context)!.noArrivals,
                        style: kArrivalsMessageStyle),
                  )
                : ArrivalsList(data),
            loading: () => Center(child: CircularProgressIndicator()),
            error: (e, stackTrace) => Center(
              child: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Text(AppLocalizations.of(context)!.arrivalsError,
                        textAlign: TextAlign.center,
                        style: kArrivalsMessageStyle),
                    SizedBox(height: 10.0),
                    Text(
                      e.toString(),
                      style: TextStyle(fontSize: 12.0),
                    )
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
