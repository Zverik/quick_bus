import 'package:flutter/material.dart';
import 'package:quick_bus/models/arrival.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:quick_bus/widgets/transport_icon.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';

class ArrivalRow extends StatelessWidget {
  final Arrival first;
  final Arrival? second;
  final bool forceExactTime;
  final scrollController = ScrollController();
  final tf = DateFormat.Hm();

  ArrivalRow(this.first, {this.second, this.forceExactTime = false});

  String formatArrivalTime(BuildContext context, Arrival arrival) {
    final arrivalSec = arrival.arrivesInSec < 0 ? 0 : arrival.arrivesInSec;
    return arrivalSec > 700 || forceExactTime
        ? tf.format(arrival.expected)
        : AppLocalizations.of(context)!.minutes((arrivalSec / 60).round());
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final firstTime = formatArrivalTime(context, first);
    String semantics = loc.arrivesText(
      '${first.route.mode.localizedName(context)} ${first.route.number}',
      first.route.headsign,
      second == null
          ? firstTime
          : "$firstTime, ${loc.next(formatArrivalTime(context, second!))}",
    );
    return Semantics(
      label: semantics,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
          child: Row(children: [
            TransitIcon(first.route),
            SizedBox(width: 10.0),
            Expanded(
              flex: 100,
              child: FadingEdgeScrollView.fromSingleChildScrollView(
                shouldDisposeScrollController: true,
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    first.route.headsign,
                    style: TextStyle(
                      fontSize: 20.0,
                    ),
                  ),
                ),
              ),
            ),
            Expanded(child: Container()),
            SizedBox(width: 10.0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  formatArrivalTime(context, first),
                  style: TextStyle(
                    fontSize: 20.0,
                    color: first.arrivesInSec < 0 ? Colors.red.shade700 : null,
                  ),
                ),
                if (second != null)
                  Text(
                    AppLocalizations.of(context)!.next(formatArrivalTime(context, second!)),
                    style: TextStyle(
                      fontSize: 12.0,
                      color: Colors.grey,
                    ),
                  ),
              ],
            ),
          ]),
        ),
      ),
    );
  }
}
