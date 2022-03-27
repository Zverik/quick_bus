import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/constants.dart';
import 'package:quick_bus/helpers/arrivals_cache.dart';
import 'package:quick_bus/helpers/lifecycle.dart';
import 'package:quick_bus/models/arrival.dart';
import 'package:quick_bus/models/bus_stop.dart';
import 'package:quick_bus/providers/arrivals.dart';
import 'package:quick_bus/providers/bookmarks.dart';
import 'package:quick_bus/providers/geolocation.dart';
import 'package:quick_bus/providers/saved_plan.dart';
import 'package:quick_bus/providers/stop_list.dart';
import 'package:quick_bus/providers/tutorial_state.dart';
import 'package:quick_bus/screens/itinerary.dart';
import 'package:quick_bus/screens/tutorial.dart';
import 'package:quick_bus/widgets/arrivals_list.dart';
import 'package:quick_bus/widgets/bookmark_row.dart';
import 'package:quick_bus/widgets/stop_map.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MonitorPage extends ConsumerStatefulWidget {
  final LatLng? location;
  MonitorPage({this.location});

  @override
  _MonitorPageState createState() => _MonitorPageState();
}

class _MonitorPageState extends ConsumerState<MonitorPage> {
  static const kSavedLocation = 'last_location';

  BusStop? nearestStop; // Stop nearest to map center
  BusStop?
      arrivalsStop; // Updated to nearestStop when needed to redraw arrivals
  List<Arrival> arrivals = []; // Arrivals for the nearest stop
  late LatLng location; // Map center location
  // LatLng? lastTrack; // Last GPS location, even when not tracking
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
  final stopMapController =
      StopMapController(); // To force location change on the map
  late LifecycleEventHandler
      lifecycleObserver; // To reset location after resuming
  DateTime? detachedOn;

  @override
  void initState() {
    super.initState();
    location =
        widget.location ?? LatLng(kDefaultLocation[0], kDefaultLocation[1]);
    if (widget.location == null) restoreLocation();

    lifecycleObserver = LifecycleEventHandler(resumed: () async {
      if (detachedOn == null ||
          DateTime.now().difference(detachedOn!).inSeconds > 120) {
        // When resuming after a minute, reset location to GPS.
        ref.read(geolocationProvider.notifier).enableTracking();
      }
      detachedOn = null;
    }, detached: () async {
      detachedOn = DateTime.now();
    });
    WidgetsBinding.instance?.addObserver(lifecycleObserver);

    _timer = Timer.periodic(Duration(seconds: 30), (timer) {
      ref.refresh(arrivalsProvider(nearestStop));
    });
    updateNearestStops();
  }

  @override
  void dispose() {
    _timer.cancel();
    WidgetsBinding.instance?.removeObserver(lifecycleObserver);
    super.dispose();
  }

  restoreLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final loc = prefs.getStringList(kSavedLocation);
    if (loc != null && ref.read(geolocationProvider) == null) {
      setState(() {
        location = LatLng(double.parse(loc[0]), double.parse(loc[1]));
      });
      stopMapController.setLocation(location);
    }
  }

  saveLocation() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(kSavedLocation,
        [location.latitude.toString(), location.longitude.toString()]);
  }

  forceUpdateNearestStops(LatLng location, bool shouldUpdateArrivals) async {
    if (nearestStopTimer != null) {
      nearestStopTimer!.cancel();
      nearestStopTimer = null;
    }
    final stopList = ref.read(stopsProvider);
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

  updateNearestStops({bool shouldUpdateArrivals = true}) {
    locationToUpdateForNearest = location;
    if (nearestStopTimer != null) return;
    nearestStopTimer = Timer(Duration(milliseconds: 300), () async {
      nearestStopTimer = null;
      forceUpdateNearestStops(
          locationToUpdateForNearest!, shouldUpdateArrivals);
    });
  }

  @override
  Widget build(BuildContext context) {
    final seenTutorial = ref.watch(seenTutorialProvider);
    final plan = ref.watch(savedPlanProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(kAppTitle),
        actions: [
          seenTutorial
              ? Container()
              : IconButton(
                  icon: Icon(Icons.help),
                  tooltip: AppLocalizations.of(context)!.openTutorial,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => TutorialPage()),
                    );
                  },
                ),
          !plan.isActive
              ? Container()
              : IconButton(
                  icon: Icon(Icons.bookmark),
                  tooltip: AppLocalizations.of(context)?.restorePlan,
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => ItineraryPage(plan.itinerary)),
                    );
                  }),
          IconButton(
            onPressed: ref.watch(trackingProvider)
                ? null
                : () {
                    ref.read(geolocationProvider.notifier).enableTracking(context);
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
                    chosenStop: nearestStop,
                    controller: stopMapController,
                    onDrag: (pos) {
                      setState(() {
                        location = pos;
                      });
                      updateNearestStops(shouldUpdateArrivals: false);
                    },
                    onDragEnd: (pos) {
                      forceUpdateNearestStops(pos, true);
                    },
                    onTrack: (pos) {
                      setState(() {
                        location = pos;
                      });
                      forceUpdateNearestStops(pos, true);
                    },
                  ),
                ],
              ),
            ),
            BookmarkRow(
              ref.watch(geolocationProvider) ?? location,
              ref.watch(bookmarkProvider),
              orientation: orientation,
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

          return SafeArea(
            top: false,
            bottom: false,
            left: false,
            child: Flex(
              direction: orientation == Orientation.portrait
                  ? Axis.vertical
                  : Axis.horizontal,
              children: children,
            ),
          );
        },
      ),
    );
  }
}
