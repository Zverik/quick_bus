import 'package:flutter/material.dart';
import 'package:quick_bus/models/route_element.dart';
import 'package:quick_bus/models/route.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class LegIcon extends StatelessWidget {
  final RouteElement leg;

  LegIcon(this.leg);

  @override
  Widget build(BuildContext context) {
    if (leg is TransitRouteElement)
      return TransitIcon((leg as TransitRouteElement).route);

    final loc = AppLocalizations.of(context)!;
    final minutes = (leg.durationSeconds / 60.0).round().toString();
    return RoutePlace(
      color: Colors.grey.shade200,
      number: minutes,
      icon: Icons.directions_walk,
      isBold: false,
      semantics: loc.walkMin(loc.minutes(minutes)),
    );
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
      semantics: '${route.mode.localizedName(context)} ${route.number}',
    );
  }
}

class RoutePlace extends StatelessWidget {
  final Color color;
  final String number;
  final IconData icon;
  final bool isBold;
  final String semantics;

  RoutePlace(
      {required this.color,
      required this.number,
      required this.icon,
      required this.isBold,
      required this.semantics});

  @override
  Widget build(BuildContext context) {
    Color foreground =
        color.computeLuminance() >= 0.8 ? Colors.black : Colors.white;

    return Semantics(
      label: semantics,
      child: ExcludeSemantics(
        child: Container(
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
        ),
      ),
    );
  }
}
