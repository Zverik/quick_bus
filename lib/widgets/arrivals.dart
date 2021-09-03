import 'package:flutter/material.dart';
import 'package:quick_bus/models/arrival.dart';
import 'package:quick_bus/models/bus_stop.dart';
import 'package:quick_bus/models/route.dart';
import 'package:quick_bus/screens/route_map.dart';
import 'package:quick_bus/widgets/arrival_row.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class ArrivalDisplayedItem {
  final Arrival first;
  Arrival? second;

  ArrivalDisplayedItem(this.first);
  bool get hasSecond => second != null;
}

class ArrivalsList extends StatelessWidget {
  final BusStop? stop;

  ArrivalsList({required this.stop});

  List<ArrivalDisplayedItem> sortArrivals() {
    if (stop == null) return [];
    var byRoute = <TransitRoute, ArrivalDisplayedItem>{};
    for (var arrival in stop!.arrivals) {
      if (!byRoute.containsKey(arrival.route))
        byRoute[arrival.route] = ArrivalDisplayedItem(arrival);
      else {
        var item = byRoute[arrival.route]!;
        if (!item.hasSecond) item.second = arrival;
      }
    }
    var arrivals = byRoute.values.toList();
    arrivals.sort((a, b) => a.first.expected.compareTo(b.first.expected));
    return arrivals;
  }

  @override
  Widget build(BuildContext context) {
    if (stop == null) {
      return Container(
        child: Text(AppLocalizations.of(context)!.noStopsNearby),
      );
    }

    final arrivals = sortArrivals();
    return ListView.separated(
      itemCount: arrivals.length,
      itemBuilder: (context, index) {
        var arrival = arrivals[index];
        return GestureDetector(
          onTap: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RoutePage(arrival.first),
                ));
          },
          child: ArrivalRow(arrival.first, second: arrival.second),
        );
      },
      separatorBuilder: (context, index) => const Divider(),
      physics: const AlwaysScrollableScrollPhysics(),
    );
  }
}
