import 'dart:async';

import 'package:flutter/material.dart';
import 'package:quick_bus/constants.dart';
import 'package:quick_bus/providers/geolocation.dart';
import 'package:quick_bus/providers/stop_list.dart';
import 'package:quick_bus/screens/monitor.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/l10n.dart';

class LoadingPage extends ConsumerStatefulWidget {
  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends ConsumerState<LoadingPage> {
  String? message;

  Future doInit() async {
    // So that we can use ref
    await Future.delayed(Duration.zero);

    // First load all bus stops.
    setState(() {
      message = AppLocalizations.of(context)?.loadingStops;
    });
    final stopList = ref.read(stopsProvider);
    await stopList.loadBusStops();

    // Then acquire user location.
    setState(() {
      message = AppLocalizations.of(context)?.acquiringLocation;
    });
    await ref.read(geolocationProvider.notifier).enableTracking(context);
    LatLng? location = ref.read(geolocationProvider);
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
