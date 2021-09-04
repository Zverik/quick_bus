import 'package:quick_bus/models/bus_stop.dart';
import 'package:quick_bus/models/arrival.dart';
import 'package:http/http.dart' as http;
import 'package:csv/csv.dart';

class SiriDownloadError extends Error {
  final String message;
  SiriDownloadError(this.message);
}

class SiriHelper {
  Future<List<Arrival>> getArrivals(BusStop stop) async {
    if (!(stop is SiriBusStop))
      throw SiriDownloadError('Stop does not have siriId: ${stop.name}');
    // http://transport.tallinn.ee/siri-stop-departures.php?stopid=1079,1080,1081&time=1390219197288
    var currentTime = DateTime.now().millisecondsSinceEpoch / 1000;
    var response = await http.get(Uri.https(
        'transport.tallinn.ee',
        '/siri-stop-departures.php',
        {'stopid': stop.siriId, 'time': currentTime.toString()}));

    if (response.statusCode == 200) {
      final parser = CsvToListConverter(
        eol: '\n',
        shouldParseNumbers: false,
      );
      List<Arrival> arrivals = [];
      bool currentStop = false;
      int? currentTimeSeconds;
      var data = parser.convert(response.body);
      for (var row in data) {
        if (row[0] == 'Transport') {
          // Header row, take current time
          currentTimeSeconds = int.parse(row[4]);
        } else if (row[0] == 'stop') {
          // Change current stop
          if (stop.siriId == row[1])
            currentStop = true;
          else {
            print('Error: missing stop ${row[1]}.');
            currentStop = false;
          }
        } else if (currentStop) {
          // Arrival line possibly
          if (Arrival.validate(row)) {
            var arrival = Arrival.fromList(stop, row,
                baseSeconds: currentTimeSeconds);
            arrivals.add(arrival);
          }
        }
      }
      return arrivals;
    } else {
      throw SiriDownloadError(
          'Failed to load schedule: ${response.statusCode}');
    }
  }
}
