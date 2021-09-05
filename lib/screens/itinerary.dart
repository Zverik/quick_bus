import 'package:flutter/material.dart';
import 'package:quick_bus/providers/saved_plan.dart';
import 'package:quick_bus/models/route_element.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:quick_bus/widgets/itinerary_leg.dart';

class ItineraryPage extends StatelessWidget {
  final List<RouteElement> itinerary;

  ItineraryPage(this.itinerary);

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat.Hm();
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${timeFormat.format(itinerary.first.departure)} — ${timeFormat.format(itinerary.last.arrival)}',
        ),
        actions: [
          Consumer(
            builder: (context, watch, child) {
              final plan = watch(savedPlanProvider).itinerary;
              final isThisPlan = plan.length == itinerary.length &&
                  itinerary.first.departure == plan.first.departure &&
                  itinerary.last.arrival == plan.last.arrival;
              return IconButton(
                icon:
                    Icon(isThisPlan ? Icons.bookmark : Icons.bookmark_outline),
                onPressed: () {
                  var planHelper = context.read(savedPlanProvider.notifier);
                  if (!isThisPlan)
                    planHelper.setPlan(itinerary);
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
          itemCount: itinerary.length,
          separatorBuilder: (context, index) => SizedBox(height: 5.0),
          itemBuilder: (context, index) => ItineraryLeg(
            itinerary[index],
            orientation: orientation,
          ),
        ),
      ),
    );
  }
}
