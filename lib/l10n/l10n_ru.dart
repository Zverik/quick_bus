// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'l10n.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get loadingStops => 'Загружаю остановки...';

  @override
  String get acquiringLocation => 'Ищу вас...';

  @override
  String get myLocation => 'Моя позиция';

  @override
  String next(String time) {
    return 'затем $time';
  }

  @override
  String get search => 'Найти...';

  @override
  String get chooseOnMap => 'Указать на карте...';

  @override
  String get showMap => 'Карта';

  @override
  String get whereTo => 'Куда едем?';

  @override
  String get newDestination => 'Новый пункт назначения';

  @override
  String get lookingForRoute => 'Ищу варианты поездок...';

  @override
  String get noRoutes => 'Нет вариантов, извините.';

  @override
  String get locationNotAccessible => 'Не построить маршрут до этой точки.';

  @override
  String get showStopNames => 'Названия остановок';

  @override
  String get loadingRoute => 'Загружаю маршрут...';

  @override
  String errorLoadingRoute(String message) {
    return 'Ошибка загрузки маршрута: $message.';
  }

  @override
  String minutes(Object value) {
    return '$value мин';
  }

  @override
  String fullMinutes(num value) {
    String _temp0 = intl.Intl.pluralLogic(
      value,
      locale: localeName,
      other: '$value минут',
      few: '$value минуты',
      one: '$value минута',
    );
    return '$_temp0';
  }

  @override
  String walkMin(Object min) {
    return 'Пешком $min';
  }

  @override
  String arrivesText(Object bus, Object headsign, Object when) {
    return '$bus на $headsign прибывает $when';
  }

  @override
  String get storePlan => 'Сохранить маршрут';

  @override
  String get restorePlan => 'Сохранённый маршрут';

  @override
  String busLeavesFrom(String bus, DateTime time, String stop) {
    final intl.DateFormat timeDateFormat = intl.DateFormat.Hm(localeName);
    final String timeString = timeDateFormat.format(time);

    return '$bus идёт в $timeString от $stop';
  }

  @override
  String walkMeters(Object distance, String destination) {
    return 'Пройдите $distance м до <b>$destination</b> (жёлтый кружок).';
  }

  @override
  String youGotTime(String minutes) {
    return 'У вас $minutes.';
  }

  @override
  String noHurry(String minutes) {
    return 'Не спешите, у вас $minutes.';
  }

  @override
  String get walkDestination => 'точки назначения';

  @override
  String stops(num stops) {
    String _temp0 = intl.Intl.pluralLogic(
      stops,
      locale: localeName,
      other: '$stops остановок',
      few: '$stops остановки',
      one: '$stops остановку',
    );
    return '$_temp0';
  }

  @override
  String waitAndRideStops(String min, String stops, String destination) {
    return 'Подождите $min и езжайте $stops до <b>$destination</b>.';
  }

  @override
  String rideStops(String stops, String destination) {
    return 'Езжайте $stops до <b>$destination</b>.';
  }

  @override
  String waitAndRideTime(String min, DateTime arrival, String destination) {
    final intl.DateFormat arrivalDateFormat = intl.DateFormat.Hm(localeName);
    final String arrivalString = arrivalDateFormat.format(arrival);

    return 'Подождите $min и езжайте до <b>$destination</b>, прибытие в $arrivalString.';
  }

  @override
  String rideTime(DateTime arrival, String destination) {
    final intl.DateFormat arrivalDateFormat = intl.DateFormat.Hm(localeName);
    final String arrivalString = arrivalDateFormat.format(arrival);

    return 'Езжайте до <b>$destination</b>, прибытие в $arrivalString.';
  }

  @override
  String get noStopsNearby =>
      'Подойдите к остановке или передвиньте карту, чтобы посмотреть расписание.';

  @override
  String get noArrivals => 'Сегодня никто не приедет.';

  @override
  String get arrivalsError => 'Не удалось загрузить расписание.';

  @override
  String get arrivalsTryAgain => 'Попробовать снова';

  @override
  String get bookmarkTarget =>
      'Перетащите сюда, чтобы начать из сохранённого места';

  @override
  String get addBookmark => 'Добавить закладку';

  @override
  String get bookmarkName => 'Название';

  @override
  String get chooseEmoji => 'Выберите значок';

  @override
  String deleteBookmark(String name) {
    return 'Удалить закладку \"$name\"?';
  }

  @override
  String get reverseRoute => 'Маршрут в другую сторону';

  @override
  String get routeBack => 'Обратный маршрут';

  @override
  String get delete => 'Удалить';

  @override
  String get enableInternet =>
      'Пожалуйста, включите интернет, чтобы можно было скачать маршруты.';

  @override
  String get enableGPS => 'Включите GPS';

  @override
  String get enableGPSMessage =>
      'Сейчас откроем панель настроек — включите в ней определение местоположения, пожалуйста.';

  @override
  String get enableLocation => 'Разрешите GPS';

  @override
  String get enableLocationMessage =>
      'Сейчас откроем панель настроек — разрешите в ней доступ к местоположению, пожалуйста.';

  @override
  String get bus => 'Автобус';

  @override
  String get trolleybus => 'Троллейбус';

  @override
  String get tram => 'Трамвай';

  @override
  String get subway => 'Метро';

  @override
  String get train => 'Поезд';

  @override
  String get ferry => 'Паром';

  @override
  String get regionalBus => 'Региональный автобус';

  @override
  String get commercialBus => 'Коммерческий автобус';

  @override
  String get openTutorial => 'Открыть инструкцию';

  @override
  String get tMainScreen => 'Первый экран';

  @override
  String get bMainScreen =>
      'Посмотрите прибывающие автобусы, подвиньте карту для выбора остановки, или нажмите на один из значков пункта назначения.';

  @override
  String get msMap => 'Карта: ваше местоположение и ближайшая остановка';

  @override
  String get msDestination => 'Куда едем: закладки и поиск';

  @override
  String get msArrivals => 'Список прибытий на выбранную остановку';

  @override
  String get tBookmarks => 'Закладки';

  @override
  String get bBookmarks =>
      'Найдя место, куда будете ездить не раз, сохраните его, нажав кнопку. Выберите эмодзи и название для закладки, чтобы строить туда маршруты одним нажатием.';

  @override
  String get tSaveThePlan => 'Сохраните маршрут';

  @override
  String get bSaveThePlan =>
      'Выбрав маршрут к цели, нажмите на значок вверху, чтобы закрепить маршрут на главном экране и не потеряться на пересадках.';

  @override
  String get tFriendRoute => 'Помогите другу';

  @override
  String get bFriendRoute =>
      'Чтобы построить маршрут к себе для друзей, постройте маршрут до них и затем разверните его кнопкой.';

  @override
  String get tutorialDone => 'Закрыть';
}
