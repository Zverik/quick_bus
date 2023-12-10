import 'package:flutter/material.dart';
import 'package:quick_bus/models/arrival.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:quick_bus/widgets/transport_icon.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';
import 'package:fading_edge_scrollview/fading_edge_scrollview.dart';

class ArrivalRow extends StatefulWidget {
  final Arrival first;
  final Arrival? second;
  final bool forceExactTime;

  ArrivalRow(this.first, {this.second, this.forceExactTime = false});

  @override
  State<ArrivalRow> createState() => _ArrivalRowState();
}

class _ArrivalRowState extends State<ArrivalRow> {
  final scrollController = ScrollController();

  final tf = DateFormat.Hm();

  String formatArrivalTime(BuildContext context, Arrival arrival) {
    final arrivalSec = arrival.arrivesInSec < 0 ? 0 : arrival.arrivesInSec;
    return arrivalSec > 700 || widget.forceExactTime
        ? tf.format(arrival.expected)
        : AppLocalizations.of(context)!.minutes((arrivalSec / 60).round());
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final firstTime = formatArrivalTime(context, widget.first);
    String semantics = loc.arrivesText(
      '${widget.first.route.mode.localizedName(context)} ${widget.first.route.number}',
      widget.first.route.headsign,
      widget.second == null
          ? firstTime
          : "$firstTime, ${loc.next(formatArrivalTime(context, widget.second!))}",
    );
    return Semantics(
      label: semantics,
      child: ExcludeSemantics(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
          child: Row(children: [
            TransitIcon(widget.first.route),
            SizedBox(width: 10.0),
            Expanded(
              flex: 100,
              child: FadingEdgeScrollView.fromSingleChildScrollView(
                child: SingleChildScrollView(
                  controller: scrollController,
                  scrollDirection: Axis.horizontal,
                  child: Text(
                    widget.first.route.headsign,
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
                  formatArrivalTime(context, widget.first),
                  style: TextStyle(
                    fontSize: 20.0,
                    color: widget.first.arrivesInSec < 0 ? Colors.red.shade700 : null,
                  ),
                ),
                if (widget.second != null)
                  Text(
                    AppLocalizations.of(context)!.next(formatArrivalTime(context, widget.second!)),
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
