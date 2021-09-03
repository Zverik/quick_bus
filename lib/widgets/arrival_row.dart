import 'package:flutter/material.dart';
import 'package:quick_bus/models/arrival.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:quick_bus/widgets/transport_icon.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class ArrivalRow extends StatelessWidget {
  final Arrival first;
  final Arrival? second;
  final bool forceExactTime;
  final tf = DateFormat.Hm();

  ArrivalRow(this.first, {this.second, this.forceExactTime = false});

  String formatArrivalTime(BuildContext context, Arrival arrival) {
    return arrival.arrivesInSec > 700 || forceExactTime
        ? tf.format(arrival.expected)
        : AppLocalizations.of(context)!.minutes((arrival.arrivesInSec / 60).ceil());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 10.0),
      child: Row(children: [
        TransitIcon(first.route),
        SizedBox(width: 10.0),
        Text(
          first.route.headsign,
          style: TextStyle(
            fontSize: 20.0,
          ),
        ),
        Expanded(child: Container()),
        Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                formatArrivalTime(context, first),
                style: TextStyle(fontSize: 20.0),
              ),
              if (second != null)
                Text(
                  AppLocalizations.of(context)!.next(formatArrivalTime(context, second!)),
                  style: TextStyle(
                    fontSize: 12.0,
                    color: Colors.grey,
                  ),
                ),
            ]),
      ]),
    );
  }
}
