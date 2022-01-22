import 'package:flutter/material.dart';
import 'package:quick_bus/models/arrival.dart';
import 'package:quick_bus/models/route.dart';
import 'package:quick_bus/screens/route_map.dart';
import 'package:quick_bus/widgets/arrival_row.dart';

class ArrivalDisplayedItem {
  final Arrival first;
  Arrival? second;

  ArrivalDisplayedItem(this.first);
  bool get hasSecond => second != null;
}

class ArrivalsList extends StatelessWidget {
  final List<Arrival> arrivals;

  ArrivalsList(this.arrivals);

  List<ArrivalDisplayedItem> sortArrivals() {
    if (arrivals.isEmpty) return [];
    var byRoute = <TransitRoute, ArrivalDisplayedItem>{};
    for (var arrival in arrivals) {
      if (arrival.arrivesInSec < 0) continue;
      if (!byRoute.containsKey(arrival.route))
        byRoute[arrival.route] = ArrivalDisplayedItem(arrival);
      else {
        var item = byRoute[arrival.route]!;
        if (!item.hasSecond) item.second = arrival;
      }
    }
    var fixedArrivals = byRoute.values.toList();
    fixedArrivals.sort((a, b) => a.first.expected.compareTo(b.first.expected));
    return fixedArrivals;
  }

  @override
  Widget build(BuildContext context) {
    if (arrivals.isEmpty) {
      return Center(child: CircularProgressIndicator());
    }

    final arrivalItems = sortArrivals();
    return ListView.separated(
      itemCount: arrivalItems.length,
      itemBuilder: (context, index) {
        var arrival = arrivalItems[index];
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
