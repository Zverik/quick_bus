import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

abstract class TransitMode {
  final String name;
  final IconData icon;
  final Color color;
  final String siriName;
  final bool isPreferred;
  final bool isRailBased;

  const TransitMode({
    required this.name,
    required this.icon,
    required this.color,
    required this.siriName,
    this.isPreferred = false,
    this.isRailBased = false,
  });

  bool isMyRouteType(int type) => false;

  static TransitMode fromRouteType(int routeType) {
    return all.firstWhere(
      (mode) => mode.isMyRouteType(routeType),
      orElse: () => bus,
    );
  }

  static TransitMode fromSiriName(String name) {
    return all.firstWhere((mode) => mode.siriName == name, orElse: () => bus);
  }

  String localizedName(BuildContext context) {
    final loc = AppLocalizations.of(context);
    return loc == null ? name : _localizedName(loc);
  }

  String _localizedName(AppLocalizations loc);

  static const bus = _TransitModeBus();
  static const trolleybus = _TransitModeTrol();
  static const tram = _TransitModeTram();
  static const subway = _TransitModeSubway();
  static const train = _TransitModeTrain();
  static const ferry = _TransitModeFerry();
  static const regional_bus = _TransitModeRegionalBus();
  static const commercial_bus = _TransitModeCommercialBus();
  static const all = [
    bus,
    trolleybus,
    tram,
    subway,
    train,
    ferry,
    regional_bus,
    commercial_bus,
  ];
}

class _TransitModeBus extends TransitMode {
  const _TransitModeBus()
      : super(
          name: 'Bus',
          icon: Icons.directions_bus,
          color: const Color(0xFF00E1B4),
          siriName: 'bus',
          isPreferred: true,
        );

  @override
  bool isMyRouteType(int type) {
    return type == 3 || type == 700;
  }

  @override
  String _localizedName(AppLocalizations loc) => loc.bus;
}

class _TransitModeTrol extends TransitMode {
  const _TransitModeTrol()
      : super(
          name: 'Trolleybus',
          icon: Icons.directions_bus,
          color: const Color(0xFF0064D7),
          siriName: 'trol',
          isPreferred: true,
        );

  @override
  bool isMyRouteType(int type) {
    return type == 11 || type == 800;
  }

  @override
  String _localizedName(AppLocalizations loc) => loc.trolleybus;
}

class _TransitModeTram extends TransitMode {
  const _TransitModeTram()
      : super(
          name: 'Tram',
          icon: Icons.tram,
          color: const Color(0xFFFF601E),
          siriName: 'tram',
          isPreferred: true,
          isRailBased: true,
        );

  @override
  bool isMyRouteType(int type) {
    return type == 0 || type == 400 || type == 900;
  }

  @override
  String _localizedName(AppLocalizations loc) => loc.tram;
}

class _TransitModeSubway extends TransitMode {
  const _TransitModeSubway()
      : super(
          name: 'Subway',
          icon: Icons.subway,
          color: const Color(0xFFD7290E),
          siriName: 'subway',
          isPreferred: true,
          isRailBased: true,
        );

  @override
  bool isMyRouteType(int type) {
    return type == 1 || type == 401 || type == 402;
  }

  @override
  String _localizedName(AppLocalizations loc) => loc.subway;
}

class _TransitModeTrain extends TransitMode {
  const _TransitModeTrain()
      : super(
          name: 'Train',
          icon: Icons.directions_train,
          color: const Color(0xFF057E00),
          siriName: 'train',
          isRailBased: true,
        );

  @override
  bool isMyRouteType(int type) {
    return type == 2 || type == 100 || type == 403;
  }

  @override
  String _localizedName(AppLocalizations loc) => loc.train;
}

class _TransitModeFerry extends TransitMode {
  const _TransitModeFerry()
      : super(
          name: 'Ferry',
          icon: Icons.directions_ferry,
          color: const Color(0xFF01428B),
          siriName: 'ferry',
        );

  @override
  bool isMyRouteType(int type) {
    return type == 4 || type == 1000 || type == 1200;
  }

  @override
  String _localizedName(AppLocalizations loc) => loc.ferry;
}

class _TransitModeRegionalBus extends TransitMode {
  const _TransitModeRegionalBus()
      : super(
          name: 'Regional Bus',
          icon: Icons.directions_bus,
          color: const Color(0xFF9A2435),
          siriName: 'regionalbus',
        );

  @override
  bool isMyRouteType(int type) {
    return type == 200 || type == 701;
  }

  @override
  String _localizedName(AppLocalizations loc) => loc.regionalBus;
}

class _TransitModeCommercialBus extends TransitMode {
  const _TransitModeCommercialBus()
      : super(
          name: 'Commercial Bus',
          icon: Icons.directions_bus,
          color: const Color(0xFF7F0086),
          siriName: 'commercialbus',
        );

  @override
  String _localizedName(AppLocalizations loc) => loc.commercialBus;
}
