import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:quick_bus/models/route_element.dart';
import 'package:quick_bus/screens/itinerary.dart';
import 'package:quick_bus/widgets/transport_icon.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter_gen/gen_l10n/l10n.dart';

class ItineraryCard extends StatelessWidget {
  final List<RouteElement> itinerary;

  ItineraryCard(this.itinerary);

  @override
  Widget build(BuildContext context) {
    final tf = DateFormat.Hm();
    var interval =
        '${tf.format(itinerary.first.departure)} — ${tf.format(itinerary.last.arrival)}';
    var duration = itinerary.last.arrival.difference(itinerary.first.departure);
    var durationStr = AppLocalizations.of(context)!.minutes(duration.inMinutes);
    String? firstStop;
    try {
      RouteElement firstTransit =
          itinerary.firstWhere((element) => element is TransitRouteElement);
      TransitRouteElement firstTRE = firstTransit as TransitRouteElement;
      firstStop = AppLocalizations.of(context)!.busLeavesFrom(
          '${firstTRE.route.mode.localizedName(context)} ${firstTRE.route.number}',
          firstTransit.departure,
          firstTransit.startName);
    } on StateError {
      // nothing
    }
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ItineraryPage(itinerary)),
        );
      },
      child: Container(
        child: Row(
          children: [
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.only(left: 10.0, top: 5.0, bottom: 5.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // First row: duration and times
                    Text(
                      interval + ' ($durationStr)',
                      style: TextStyle(
                        fontSize: 20.0,
                        // fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 10.0),
                    // Second row: diagram for modes
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [for (var leg in itinerary) LegIcon(leg)],
                      ),
                    ),
                    // Third row: "Leaves at 12:43 from stop StopName" (do we need it?)
                    if (firstStop != null) ...[
                      SizedBox(height: 10.0),
                      Text(
                        firstStop,
                        style: TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            Icon(Icons.navigate_next),
          ],
        ),
      ),
    );
  }
}
