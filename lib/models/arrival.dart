import 'package:csv/csv.dart';
import 'package:intl/intl.dart' show DateFormat;
import 'package:quick_bus/models/modes.dart';
import 'package:quick_bus/models/route.dart';
import 'package:quick_bus/models/bus_stop.dart';

class Arrival {
  final TransitRoute route;
  final BusStop stop;
  final DateTime? _expected;
  final DateTime scheduled;

  static final _converter = CsvToListConverter();
  static final tf = DateFormat.Hm();

  Arrival({
    required this.route,
    required this.stop,
    DateTime? expected,
    required this.scheduled,
  }) : _expected = expected;

  bool get isPredicted => _expected != null;
  DateTime get expected => _expected ?? scheduled;
  int get arrivesInSec => expected.difference(DateTime.now()).inSeconds;

  factory Arrival.fromList(BusStop stop, List<dynamic> parts,
      {int? baseSeconds}) {
    // Transport,RouteNum,ExpectedTimeInSeconds,ScheduleTimeInSeconds,51267,version20201024
    // bus,5,54655,54629,Metsakooli tee,211,Z
    if (baseSeconds == null) {
      var now = DateTime.now();
      baseSeconds = now.second + now.minute * 60 + now.hour * 3600;
    }
    return Arrival(
      stop: stop,
      route: TransitRoute(
        mode: TransitMode.fromSiriName(parts[0]),
        number: parts[1],
        headsign: parts[4],
      ),
      expected: secondsToDateTime(int.parse(parts[2])),
      scheduled: secondsToDateTime(int.parse(parts[3])),
    );
  }

  static DateTime secondsToDateTime(int seconds) {
    var now = DateTime.now();
    var hours = seconds ~/ 3600;
    var minutesSeconds = seconds % 3600;
    return DateTime(now.year, now.month, now.day, hours, minutesSeconds ~/ 60,
        minutesSeconds % 60);
  }

  factory Arrival.fromLine(BusStop stop, String line) {
    var parts = _converter.convert(line, shouldParseNumbers: false);
    return Arrival.fromList(stop, parts[0]);
  }

  static bool validate(List<dynamic> parts) {
    if (parts.length < 5) return false;
    if (parts.sublist(0, 4).any((element) => element.length == 0)) return false;
    // TODO
    return true;
  }

  @override
  String toString() {
    return 'Arrival($route at $stop: ${tf.format(scheduled)} exp. ${tf.format(expected)}';
  }
}
