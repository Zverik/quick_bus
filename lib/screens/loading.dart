import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:quick_bus/constants.dart';
import 'package:quick_bus/helpers/equirectangular.dart';
import 'package:quick_bus/providers/stop_list.dart';
import 'package:quick_bus/screens/monitor.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class LoadingPage extends StatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  String? message;

  Future<LatLng?> getFirstLocation() async {
    // TODO: check for permissions
    try {
      final loc = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: Duration(seconds: 5),
      );
      return LatLng(loc.latitude, loc.longitude);
    } on TimeoutException {
      // ?
    } on LocationServiceDisabledException {
      // ?
    } on PermissionDeniedException {
      // ?
    }
  }

  Future doInit() async {
    // So that we can use context
    await Future.delayed(Duration.zero);

    // First load all bus stops.
    setState(() {
      message = AppLocalizations.of(context)?.loadingStops;
    });
    final stopList = context.read(stopsProvider);
    await stopList.loadBusStops();

    // Then acquire user location.
    setState(() {
      message = AppLocalizations.of(context)?.acquiringLocation;
    });
    LatLng? location = await getFirstLocation();
    // Finally switch to the monitor page.
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => MonitorPage(location: location)),
    );
  }

  @override
  void initState() {
    super.initState();
    doInit();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(kAppTitle),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              value: null,
              color: Colors.blueGrey,
            ),
            SizedBox(height: 40.0),
            Text(
              message ?? 'Initializing...',
              style: TextStyle(fontSize: 20.0),
            ),
          ],
        ),
      ),
    );
  }
}
