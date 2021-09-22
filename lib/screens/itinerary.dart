import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quick_bus/constants.dart';
import 'package:quick_bus/providers/saved_plan.dart';
import 'package:quick_bus/models/route_element.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_bus/widgets/itinerary_leg.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:latlong2/latlong.dart';

class ItineraryPage extends StatefulWidget {
  final List<RouteElement> itinerary;

  ItineraryPage(this.itinerary);

  @override
  _ItineraryPageState createState() => _ItineraryPageState();
}

class _ItineraryPageState extends State<ItineraryPage> {
  late StreamSubscription<Position> locSub;
  late Timer updateTimer;
  LatLng? location;

  @override
  void initState() {
    super.initState();
    locSub = Geolocator.getPositionStream(
      intervalDuration: Duration(seconds: 3),
      desiredAccuracy: LocationAccuracy.high,
    ).listen((pos) {
      setState(() {
        location = LatLng(pos.latitude, pos.longitude);
      });
    }, cancelOnError: true);
    updateTimer = Timer.periodic(Duration(minutes: 1), (timer) {
      // Just redraw the page to hide outdated itinerary legs.
      setState(() { });
    });
  }

  @override
  void dispose() {
    locSub.cancel();
    updateTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.Hm();
    // Step N-1 if N's departure is less than kHide minutes ago, otherwise N.
    var startIndex = widget.itinerary.indexWhere((element) =>
        element.departure.isAfter(DateTime.now()
            .subtract(Duration(minutes: kHideItineraryLegAfter))));
    // -1 if not found, that is, the entire itinerary is in the past.
    startIndex = startIndex == 0 ? 0 : startIndex < 0 ? widget.itinerary.length - 1 : startIndex - 1;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${timeFormat.format(widget.itinerary.first.departure)} — ${timeFormat.format(widget.itinerary.last.arrival)}',
        ),
        actions: [
          Consumer(
            builder: (context, watch, child) {
              final plan = watch(savedPlanProvider).itinerary;
              final isThisPlan = plan.length == widget.itinerary.length &&
                  widget.itinerary.first.departure == plan.first.departure &&
                  widget.itinerary.last.arrival == plan.last.arrival;
              return IconButton(
                icon:
                    Icon(isThisPlan ? Icons.bookmark : Icons.bookmark_outline),
                tooltip: AppLocalizations.of(context)?.storePlan,
                onPressed: () {
                  var planHelper = context.read(savedPlanProvider.notifier);
                  if (!isThisPlan)
                    planHelper.setPlan(widget.itinerary);
                  else
                    planHelper.clearPlan();
                },
              );
            },
          ),
        ],
      ),
      body: OrientationBuilder(
        builder: (context, orientation) => ListView.separated(
          itemCount: widget.itinerary.length - startIndex,
          separatorBuilder: (context, index) => SizedBox(height: 5.0),
          itemBuilder: (context, index) => ItineraryLeg(
            widget.itinerary[index + startIndex],
            orientation: orientation,
            location: location,
          ),
        ),
      ),
    );
  }
}
