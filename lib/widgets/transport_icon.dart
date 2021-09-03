import 'package:flutter/material.dart';
import 'package:quick_bus/models/route_element.dart';
import 'package:quick_bus/models/route.dart';

class LegIcon extends StatelessWidget {
  final RouteElement leg;

  LegIcon(this.leg);

  @override
  Widget build(BuildContext context) {
    Color background = Colors.white;
    IconData icon = Icons.error_outline;
    String number = '';
    bool isBold = false;

    if (leg is WalkRouteElement) {
      background = Colors.grey.shade200;
      icon = Icons.directions_walk;
      number = (leg.durationSeconds / 60.0).round().toString();
    } else {
      var mode = (leg as TransitRouteElement).route.mode;
      number = (leg as TransitRouteElement).route.number;
      isBold = true;
      icon = mode.icon;
      background = mode.color;
    }

    return RoutePlace(
        color: background, number: number, icon: icon, isBold: isBold);
  }
}

class TransitIcon extends StatelessWidget {
  final TransitRoute route;

  TransitIcon(this.route);

  @override
  Widget build(BuildContext context) {
    return RoutePlace(
      color: route.mode.color,
      number: route.number,
      icon: route.mode.icon,
      isBold: true,
    );
  }
}

class RoutePlace extends StatelessWidget {
  final Color color;
  final String number;
  final IconData icon;
  final bool isBold;

  RoutePlace(
      {required this.color,
      required this.number,
      required this.icon,
      required this.isBold});

  @override
  Widget build(BuildContext context) {
    Color foreground =
        color.computeLuminance() >= 0.8 ? Colors.black : Colors.white;

    return Container(
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 10.0),
      margin: EdgeInsets.symmetric(horizontal: 2.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(5.0),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: foreground,
            size: 20.0,
          ),
          Text(
            number,
            style: TextStyle(
              color: foreground,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              fontSize: 20.0,
            ),
          ),
        ],
      ),
    );
  }
}
