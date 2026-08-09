// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Estonian (`et`).
class AppLocalizationsEt extends AppLocalizations {
  AppLocalizationsEt([String locale = 'et']) : super(locale);

  @override
  String get loadingStops => 'Laen peatused...';

  @override
  String get acquiringLocation => 'Otsin teie...';

  @override
  String get myLocation => 'Minu asukoht';

  @override
  String next(String time) {
    return 'ning $time';
  }

  @override
  String get search => 'Otsing';

  @override
  String get chooseOnMap => 'Valida kaardil...';

  @override
  String get showMap => 'Kaart';

  @override
  String get whereTo => 'Kuhu sõidame?';

  @override
  String get newDestination => 'Uus suund';

  @override
  String get lookingForRoute => 'Otsin marsruuti...';

  @override
  String get noRoutes => 'Vabandust, marsruute ei leitud.';

  @override
  String get locationNotAccessible => 'Sellise suunaga marsruute ei leitud.';

  @override
  String get showStopNames => 'Peatuste nimed';

  @override
  String get loadingRoute => 'Marsruudi laadimine...';

  @override
  String errorLoadingRoute(String message) {
    return 'Marsruudi laadimisel tekkis viga: $message.';
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
      other: '$value minutit',
      few: '$value minutit',
      one: '$value minut',
    );
    return '$_temp0';
  }

  @override
  String walkMin(Object min) {
    return 'Jalutage $min';
  }

  @override
  String arrivesText(Object bus, Object headsign, Object when) {
    return '$bus suunaga <b>$headsign</b> saabub $when';
  }

  @override
  String get storePlan => 'Salvesta marsruut';

  @override
  String get restorePlan => 'Marsruut salvestatud';

  @override
  String busLeavesFrom(String bus, DateTime time, String stop) {
    final intl.DateFormat timeDateFormat = intl.DateFormat.Hm(localeName);
    final String timeString = timeDateFormat.format(time);

    return '$bus väljub kell $timeString peatusest $stop';
  }

  @override
  String walkMeters(Object distance, String destination) {
    return 'Jalutage ${distance}m <b>$destination</b> (kollane ring).';
  }

  @override
  String youGotTime(String minutes) {
    return 'Teil on $minutes.';
  }

  @override
  String noHurry(String minutes) {
    return 'Ärge kiirustage, teil on veel $minutes.';
  }

  @override
  String get walkDestination => 'suund';

  @override
  String stops(num stops) {
    String _temp0 = intl.Intl.pluralLogic(
      stops,
      locale: localeName,
      other: '$stops peatust',
      one: '$stops peatus',
    );
    return '$_temp0';
  }

  @override
  String waitAndRideStops(String min, String stops, String destination) {
    return 'Oodake $min ja sõitke $stops peatuseni <b>$destination</b>.';
  }

  @override
  String rideStops(String stops, String destination) {
    return 'Sõitke $stops peatuseni <b>$destination</b>.';
  }

  @override
  String waitAndRideTime(String min, DateTime arrival, String destination) {
    final intl.DateFormat arrivalDateFormat = intl.DateFormat.Hm(localeName);
    final String arrivalString = arrivalDateFormat.format(arrival);

    return 'Oodake $min ja sõida kuni kella $arrivalString peatuseni <b>$destination</b>.';
  }

  @override
  String rideTime(DateTime arrival, String destination) {
    final intl.DateFormat arrivalDateFormat = intl.DateFormat.Hm(localeName);
    final String arrivalString = arrivalDateFormat.format(arrival);

    return 'Sõida kuni kella $arrivalString peatuseni <b>$destination</b>.';
  }

  @override
  String get noStopsNearby =>
      'Saabumisaegade vaatamiseks tulge peatusele lähemale või lohistage kaarti.';

  @override
  String get noArrivals => 'Täna pole saabumisi.';

  @override
  String get arrivalsError => 'Saabumise ajakava ei saanud värskendada.';

  @override
  String get arrivalsTryAgain => 'Proovi uuesti';

  @override
  String get bookmarkTarget => 'Lohistage siia, et alustada salvestatud kohast';

  @override
  String get addBookmark => 'Lisage järjehoidja';

  @override
  String get bookmarkName => 'Järjehoidja nimi';

  @override
  String get chooseEmoji => 'Valige emotikon';

  @override
  String deleteBookmark(String name) {
    return 'Kas kustutada järjehoidja \"$name\"?';
  }

  @override
  String get reverseRoute => 'Vastupidine marsruut';

  @override
  String get routeBack => 'Marsruut tagasi';

  @override
  String get delete => 'Kustutada';

  @override
  String get enableInternet =>
      'Palun lülitage võrgule juurdepääs sisse, muidu ei saa ma marsruudi andmeid kätte.';

  @override
  String get enableGPS => 'GPS lubamine';

  @override
  String get enableGPSMessage =>
      'Lülitage kuvataval seadete paneelil asukohateenused sisse.';

  @override
  String get enableLocation => 'Luba asukoht';

  @override
  String get enableLocationMessage =>
      'Lubage kuvataval seadete paneelil rakendusele juurdepääs asukohale.';

  @override
  String get bus => 'Buss';

  @override
  String get trolleybus => 'Troll';

  @override
  String get tram => 'Tramm';

  @override
  String get subway => 'Metroo';

  @override
  String get train => 'Rong';

  @override
  String get ferry => 'Praam';

  @override
  String get regionalBus => 'Kaugliinibuss';

  @override
  String get commercialBus => 'Kommertsbuss';

  @override
  String get openTutorial => 'Ava juhised';

  @override
  String get tMainScreen => 'Põhiekraan';

  @override
  String get bMainScreen =>
      'Lohistage kaarti, et valida lähedal asuv peatus, vaadake selle saabumisaegu või puudutage mis tahes sihtkoha ikooni.';

  @override
  String get msMap => 'Kaart: teie asukoht ja lähimad peatused';

  @override
  String get msDestination => 'Sihtkoht: järjehoidjad ja otsing';

  @override
  String get msArrivals => 'Saabumised valitud peatusesse';

  @override
  String get tBookmarks => 'Järjehoidjad';

  @override
  String get bBookmarks =>
      'Pärast tuttava sihtkoha valimist salvestage see, puudutades nuppu. Valige järjehoidjale emotikon ja nimi, et planeerida marsruute ühe puudutusega.';

  @override
  String get tSaveThePlan => 'Salvesta plaan';

  @override
  String get bSaveThePlan =>
      'Pärast marsruudi valimist puudutage ikooni, et see põhiekraanile kinnitada, et saaksite pärast bussist lahkumist teada, kuhu minna.';

  @override
  String get tFriendRoute => 'Aidake sõpra';

  @override
  String get bFriendRoute =>
      'Sõbra jaoks marsruudi kavandamiseks ehitage neile marsruudile nagu tavaliselt ja seejärel puudutage selle ümberpööramiseks nuppu.';

  @override
  String get tutorialDone => 'Valmis';
}
