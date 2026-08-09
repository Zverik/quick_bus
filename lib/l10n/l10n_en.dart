// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get loadingStops => 'Loading stops...';

  @override
  String get acquiringLocation => 'Finding you...';

  @override
  String get myLocation => 'My Location';

  @override
  String next(String time) {
    return 'next $time';
  }

  @override
  String get search => 'Search...';

  @override
  String get chooseOnMap => 'Choose on a map...';

  @override
  String get showMap => 'Map';

  @override
  String get whereTo => 'Where to?';

  @override
  String get newDestination => 'New Destination';

  @override
  String get lookingForRoute => 'Looking for a route...';

  @override
  String get noRoutes => 'No routes found, sorry.';

  @override
  String get locationNotAccessible => 'Cannot find a route to the destination.';

  @override
  String get showStopNames => 'Stop names';

  @override
  String get loadingRoute => 'Loading the route...';

  @override
  String errorLoadingRoute(String message) {
    return 'Error loading route: $message.';
  }

  @override
  String minutes(Object value) {
    return '$value min';
  }

  @override
  String fullMinutes(num value) {
    String _temp0 = intl.Intl.pluralLogic(
      value,
      locale: localeName,
      other: '$value minutes',
      few: '$value minutes',
      one: '$value minute',
    );
    return '$_temp0';
  }

  @override
  String walkMin(Object min) {
    return 'Walk $min';
  }

  @override
  String arrivesText(Object bus, Object headsign, Object when) {
    return '$bus to $headsign arrives $when';
  }

  @override
  String get storePlan => 'Save route plan';

  @override
  String get restorePlan => 'Stored route plan';

  @override
  String busLeavesFrom(String bus, DateTime time, String stop) {
    final intl.DateFormat timeDateFormat = intl.DateFormat.Hm(localeName);
    final String timeString = timeDateFormat.format(time);

    return '$bus leaves at $timeString from $stop';
  }

  @override
  String walkMeters(Object distance, String destination) {
    return 'Walk $distance m to <b>$destination</b> (the yellow circle).';
  }

  @override
  String youGotTime(String minutes) {
    return 'You\'ve got $minutes.';
  }

  @override
  String noHurry(String minutes) {
    return 'Don\'t hurry, you\'ve got $minutes.';
  }

  @override
  String get walkDestination => 'destination';

  @override
  String stops(num stops) {
    String _temp0 = intl.Intl.pluralLogic(
      stops,
      locale: localeName,
      other: '$stops stops',
      few: '$stops stops',
      one: '$stops stop',
    );
    return '$_temp0';
  }

  @override
  String waitAndRideStops(String min, String stops, String destination) {
    return 'Wait for $min and ride $stops to <b>$destination</b>.';
  }

  @override
  String rideStops(String stops, String destination) {
    return 'Ride $stops to <b>$destination</b>.';
  }

  @override
  String waitAndRideTime(String min, DateTime arrival, String destination) {
    final intl.DateFormat arrivalDateFormat = intl.DateFormat.Hm(localeName);
    final String arrivalString = arrivalDateFormat.format(arrival);

    return 'Wait $min and ride until $arrivalString to <b>$destination</b>.';
  }

  @override
  String rideTime(DateTime arrival, String destination) {
    final intl.DateFormat arrivalDateFormat = intl.DateFormat.Hm(localeName);
    final String arrivalString = arrivalDateFormat.format(arrival);

    return 'Ride until $arrivalString to <b>$destination</b>.';
  }

  @override
  String get noStopsNearby =>
      'Please find a stop or move the map to see arrival times.';

  @override
  String get noArrivals => 'No arrivals today.';

  @override
  String get arrivalsError => 'Could not update arrivals.';

  @override
  String get arrivalsTryAgain => 'Try again';

  @override
  String get bookmarkTarget => 'Drag here to set starting location';

  @override
  String get addBookmark => 'Add Bookmark';

  @override
  String get bookmarkName => 'Bookmark name';

  @override
  String get chooseEmoji => 'Choose an emoji';

  @override
  String deleteBookmark(String name) {
    return 'Delete bookmark \"$name\"?';
  }

  @override
  String get reverseRoute => 'Reverse route';

  @override
  String get routeBack => 'Route back';

  @override
  String get delete => 'Delete';

  @override
  String get enableInternet =>
      'Please turn on network access, otherwise I cannot get route data.';

  @override
  String get enableGPS => 'Enable GPS';

  @override
  String get enableGPSMessage =>
      'Please turn on the location services in the settings panel that will be shown.';

  @override
  String get enableLocation => 'Enable Location';

  @override
  String get enableLocationMessage =>
      'Please allow location access for the app in the settings panel that will be shown.';

  @override
  String get bus => 'Bus';

  @override
  String get trolleybus => 'Trolleybus';

  @override
  String get tram => 'Tram';

  @override
  String get subway => 'Subway';

  @override
  String get train => 'Train';

  @override
  String get ferry => 'Ferry';

  @override
  String get regionalBus => 'Regional Bus';

  @override
  String get commercialBus => 'Commercial Bus';

  @override
  String get openTutorial => 'Open the tutorial';

  @override
  String get tMainScreen => 'Main Screen';

  @override
  String get bMainScreen =>
      'Drag the map to choose a nearby stop, consult the arrival times for it, or tap any of the destination icons.';

  @override
  String get msMap => 'Map: your location and the nearest stop';

  @override
  String get msDestination => 'Destination: bookmarks and search';

  @override
  String get msArrivals => 'Arrivals for the chosen stop';

  @override
  String get tBookmarks => 'Bookmarks';

  @override
  String get bBookmarks =>
      'After choosing a familiar destination, save it by tapping the button. Choose an emoji and a name for your bookmark, to plan routes with a single tap.';

  @override
  String get tSaveThePlan => 'Save the Plan';

  @override
  String get bSaveThePlan =>
      'Having chosen a route, tap the icon to pin it to the main screen, so that you know where to go after leaving a bus.';

  @override
  String get tFriendRoute => 'Help a Friend';

  @override
  String get bFriendRoute =>
      'To plan a route for your friend towards you, build one to them as usual, and then tap the button to reverse it.';

  @override
  String get tutorialDone => 'Done';
}
