import 'package:quick_bus/models/bus_stop.dart';
import 'package:quick_bus/models/arrival.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

class SiriDownloadError extends Error {
  final String message;
  SiriDownloadError(this.message);
}

class SiriHelper {
  Future updateArrivals(List<BusStop> stops) async {
    if (stops.isEmpty) return;
    for (var stop in stops) stop.arrivals.clear();

    // http://transport.tallinn.ee/siri-stop-departures.php?stopid=1079,1080,1081&time=1390219197288
    var currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
    var stopId = stops.map((stop) => (stop as SiriBusStop).siriId).join(',');
    var response = await http.get(Uri.https(
        'transport.tallinn.ee',
        '/siri-stop-departures.php',
        {'stopid': stopId, 'time': currentTime.toString()}));

    if (response.statusCode == 200) {
      final parser = CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      );
      BusStop? currentStop;
      int? currentTimeSeconds;
      var data = parser.convert(response.body);
      for (var row in data) {
        if (row[0] == 'Transport') {
          // Header row, take current time
          currentTimeSeconds = int.parse(row[4]);
        } else if (row[0] == 'stop') {
          // Change current stop
          try {
            currentStop = stops
                .singleWhere((stop) => (stop as SiriBusStop).siriId == row[1]);
            currentStop.arrivals.clear();
          } on StateError {
            print('Error: missing stop ${row[1]}.');
            currentStop = null;
          }
        } else if (currentStop != null) {
          // Arrival line possibly
          if (Arrival.validate(row)) {
            var arrival = Arrival.fromList(currentStop, row,
                baseSeconds: currentTimeSeconds);
            currentStop.arrivals.add(arrival);
          }
        }
      }
    } else {
      throw SiriDownloadError(
          'Failed to load schedule: ${response.statusCode}');
    }
  }
}
