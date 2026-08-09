import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'l10n_en.dart';
import 'l10n_et.dart';
import 'l10n_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/l10n.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('et'),
    Locale('ru'),
  ];

  /// First string people see, when stops are loading.
  ///
  /// In en, this message translates to:
  /// **'Loading stops...'**
  String get loadingStops;

  /// On the loading screen, a message when acquiring geolocation.
  ///
  /// In en, this message translates to:
  /// **'Finding you...'**
  String get acquiringLocation;

  /// Accessibility label for my location button on the main screen.
  ///
  /// In en, this message translates to:
  /// **'My Location'**
  String get myLocation;

  /// For the timetable, prefix for next arrival ('next 12:30'). Keep it short.
  ///
  /// In en, this message translates to:
  /// **'next {time}'**
  String next(String time);

  /// Placeholder for the search text field.
  ///
  /// In en, this message translates to:
  /// **'Search...'**
  String get search;

  /// Item in the search panel to direct to the map for choosing a destination.
  ///
  /// In en, this message translates to:
  /// **'Choose on a map...'**
  String get chooseOnMap;

  /// Accessibility label for a map icon next to a search result.
  ///
  /// In en, this message translates to:
  /// **'Map'**
  String get showMap;

  /// Title for the page where you choose a destination on a map.
  ///
  /// In en, this message translates to:
  /// **'Where to?'**
  String get whereTo;

  /// Title for the planned routes list when you chose a destination on a map.
  ///
  /// In en, this message translates to:
  /// **'New Destination'**
  String get newDestination;

  /// Text displayed when the app is looking for routes to a destination.
  ///
  /// In en, this message translates to:
  /// **'Looking for a route...'**
  String get lookingForRoute;

  /// When no routes to a destination found.
  ///
  /// In en, this message translates to:
  /// **'No routes found, sorry.'**
  String get noRoutes;

  /// OpenTripPlanner error when it cannot build a route.
  ///
  /// In en, this message translates to:
  /// **'Cannot find a route to the destination.'**
  String get locationNotAccessible;

  /// Accessibility text for a button to show stop names on a map.
  ///
  /// In en, this message translates to:
  /// **'Stop names'**
  String get showStopNames;

  /// Text displayed when loading a specific route.
  ///
  /// In en, this message translates to:
  /// **'Loading the route...'**
  String get loadingRoute;

  /// When loading a route for a route map failed.
  ///
  /// In en, this message translates to:
  /// **'Error loading route: {message}.'**
  String errorLoadingRoute(String message);

  /// Shorthand for minutes, used like '3 min'.
  ///
  /// In en, this message translates to:
  /// **'{value} min'**
  String minutes(Object value);

  /// Duration in minutes.
  ///
  /// In en, this message translates to:
  /// **'{value,plural, =1{{value} minute} few{{value} minutes} other{{value} minutes}}'**
  String fullMinutes(num value);

  /// Accessibility text for walking N minutes.
  ///
  /// In en, this message translates to:
  /// **'Walk {min}'**
  String walkMin(Object min);

  /// Accessibility text for an arrival row.
  ///
  /// In en, this message translates to:
  /// **'{bus} to {headsign} arrives {when}'**
  String arrivesText(Object bus, Object headsign, Object when);

  /// Accessibility text for the route plan bookmark button.
  ///
  /// In en, this message translates to:
  /// **'Save route plan'**
  String get storePlan;

  /// Accessibility text for the route plan button on the main screen.
  ///
  /// In en, this message translates to:
  /// **'Stored route plan'**
  String get restorePlan;

  /// Subtitle for a planned route. Used like 'Tram 2 leaves at 11:34 from Balti jaam'.
  ///
  /// In en, this message translates to:
  /// **'{bus} leaves at {time} from {stop}'**
  String busLeavesFrom(String bus, DateTime time, String stop);

  /// Itinerary text for walking.
  ///
  /// In en, this message translates to:
  /// **'Walk {distance} m to <b>{destination}</b> (the yellow circle).'**
  String walkMeters(Object distance, String destination);

  /// Comment about walking time.
  ///
  /// In en, this message translates to:
  /// **'You\'ve got {minutes}.'**
  String youGotTime(String minutes);

  /// Comment about walking time when the speed is very low.
  ///
  /// In en, this message translates to:
  /// **'Don\'t hurry, you\'ve got {minutes}.'**
  String noHurry(String minutes);

  /// Generic name of a destination waypoint.
  ///
  /// In en, this message translates to:
  /// **'destination'**
  String get walkDestination;

  /// Number of stops for an itinerary text.
  ///
  /// In en, this message translates to:
  /// **'{stops,plural, =1{{stops} stop} few{{stops} stops} other{{stops} stops}}'**
  String stops(num stops);

  /// Itinerary text for riding a few stops after waiting.
  ///
  /// In en, this message translates to:
  /// **'Wait for {min} and ride {stops} to <b>{destination}</b>.'**
  String waitAndRideStops(String min, String stops, String destination);

  /// Itinerary text for riding a few stops.
  ///
  /// In en, this message translates to:
  /// **'Ride {stops} to <b>{destination}</b>.'**
  String rideStops(String stops, String destination);

  /// Itinerary text for riding until a specified time after waiting.
  ///
  /// In en, this message translates to:
  /// **'Wait {min} and ride until {arrival} to <b>{destination}</b>.'**
  String waitAndRideTime(String min, DateTime arrival, String destination);

  /// Itinerary text for riding until a specified time.
  ///
  /// In en, this message translates to:
  /// **'Ride until {arrival} to <b>{destination}</b>.'**
  String rideTime(DateTime arrival, String destination);

  /// Message on an arrivals panel when there is no active stop.
  ///
  /// In en, this message translates to:
  /// **'Please find a stop or move the map to see arrival times.'**
  String get noStopsNearby;

  /// Message on an arrivals panel when the list is empty.
  ///
  /// In en, this message translates to:
  /// **'No arrivals today.'**
  String get noArrivals;

  /// Message on an arrivals panel when there's a network error.
  ///
  /// In en, this message translates to:
  /// **'Could not update arrivals.'**
  String get arrivalsError;

  /// Button label for refreshing the arrivals list in case of an error.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get arrivalsTryAgain;

  /// When dragging a bookmark, this text appears on top of the map.
  ///
  /// In en, this message translates to:
  /// **'Drag here to set starting location'**
  String get bookmarkTarget;

  /// Bookmark screen title.
  ///
  /// In en, this message translates to:
  /// **'Add Bookmark'**
  String get addBookmark;

  /// Hint on the bookmark adding screen.
  ///
  /// In en, this message translates to:
  /// **'Bookmark name'**
  String get bookmarkName;

  /// Hint for the emoji picked on the bookmark adding screen.
  ///
  /// In en, this message translates to:
  /// **'Choose an emoji'**
  String get chooseEmoji;

  /// Text on a panel for deleting a bookmark.
  ///
  /// In en, this message translates to:
  /// **'Delete bookmark \"{name}\"?'**
  String deleteBookmark(String name);

  /// Tooltip text for an icon to reverse a route.
  ///
  /// In en, this message translates to:
  /// **'Reverse route'**
  String get reverseRoute;

  /// Title of a route after pressing the 'reverse' button.
  ///
  /// In en, this message translates to:
  /// **'Route back'**
  String get routeBack;

  /// Button text for bookmark deletion.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// Shown when both wi-fi and data are off.
  ///
  /// In en, this message translates to:
  /// **'Please turn on network access, otherwise I cannot get route data.'**
  String get enableInternet;

  /// Title of the alert for enabling location services.
  ///
  /// In en, this message translates to:
  /// **'Enable GPS'**
  String get enableGPS;

  /// Contents of the alert for enabling location services.
  ///
  /// In en, this message translates to:
  /// **'Please turn on the location services in the settings panel that will be shown.'**
  String get enableGPSMessage;

  /// Title of the alert for allowing app access to location.
  ///
  /// In en, this message translates to:
  /// **'Enable Location'**
  String get enableLocation;

  /// Contents of the alert for allowing app access to location.
  ///
  /// In en, this message translates to:
  /// **'Please allow location access for the app in the settings panel that will be shown.'**
  String get enableLocationMessage;

  /// Transit mode name.
  ///
  /// In en, this message translates to:
  /// **'Bus'**
  String get bus;

  /// Transit mode name.
  ///
  /// In en, this message translates to:
  /// **'Trolleybus'**
  String get trolleybus;

  /// Transit mode name.
  ///
  /// In en, this message translates to:
  /// **'Tram'**
  String get tram;

  /// Transit mode name.
  ///
  /// In en, this message translates to:
  /// **'Subway'**
  String get subway;

  /// Transit mode name.
  ///
  /// In en, this message translates to:
  /// **'Train'**
  String get train;

  /// Transit mode name.
  ///
  /// In en, this message translates to:
  /// **'Ferry'**
  String get ferry;

  /// Transit mode name.
  ///
  /// In en, this message translates to:
  /// **'Regional Bus'**
  String get regionalBus;

  /// Transit mode name.
  ///
  /// In en, this message translates to:
  /// **'Commercial Bus'**
  String get commercialBus;

  /// AppBar icon label for opening the tutorial.
  ///
  /// In en, this message translates to:
  /// **'Open the tutorial'**
  String get openTutorial;

  /// Title for the first tutorial page.
  ///
  /// In en, this message translates to:
  /// **'Main Screen'**
  String get tMainScreen;

  /// Description for the main screen tutorial page.
  ///
  /// In en, this message translates to:
  /// **'Drag the map to choose a nearby stop, consult the arrival times for it, or tap any of the destination icons.'**
  String get bMainScreen;

  /// Upper part of the main screen.
  ///
  /// In en, this message translates to:
  /// **'Map: your location and the nearest stop'**
  String get msMap;

  /// Middle part of the main screen.
  ///
  /// In en, this message translates to:
  /// **'Destination: bookmarks and search'**
  String get msDestination;

  /// Lower part of the main screen.
  ///
  /// In en, this message translates to:
  /// **'Arrivals for the chosen stop'**
  String get msArrivals;

  /// Title for the second tutorial page.
  ///
  /// In en, this message translates to:
  /// **'Bookmarks'**
  String get tBookmarks;

  /// Description for the bookmarks tutorial page.
  ///
  /// In en, this message translates to:
  /// **'After choosing a familiar destination, save it by tapping the button. Choose an emoji and a name for your bookmark, to plan routes with a single tap.'**
  String get bBookmarks;

  /// Title for the third tutorial page.
  ///
  /// In en, this message translates to:
  /// **'Save the Plan'**
  String get tSaveThePlan;

  /// Description for the plan tutorial page.
  ///
  /// In en, this message translates to:
  /// **'Having chosen a route, tap the icon to pin it to the main screen, so that you know where to go after leaving a bus.'**
  String get bSaveThePlan;

  /// Title for the fourth tutorial page.
  ///
  /// In en, this message translates to:
  /// **'Help a Friend'**
  String get tFriendRoute;

  /// Description for the friend route page.
  ///
  /// In en, this message translates to:
  /// **'To plan a route for your friend towards you, build one to them as usual, and then tap the button to reverse it.'**
  String get bFriendRoute;

  /// Button text for closing the tutorial.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get tutorialDone;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'et', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'et':
      return AppLocalizationsEt();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
