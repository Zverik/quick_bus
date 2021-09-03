import 'dart:ui';
import 'modes.dart';

class TransitRoute {
  String? _otpId;
  bool checkedOtpId = false;
  TransitMode mode;
  String number;
  String headsign;

  TransitRoute(
      {required this.number, required this.headsign, required this.mode});

  factory TransitRoute.query(String otpId) {
    // TODO
    return TransitRoute(number: '0', headsign: 'Error', mode: TransitMode.bus);
  }

  factory TransitRoute.fromGtfsIdHack(String gtfsId) {
    final re = RegExp(r'_([a-z]+)_(\w+)$');
    var match = re.firstMatch(gtfsId);
    if (match == null) throw Exception('Cannot parse route id $gtfsId');

    return TransitRoute(
      number: match.group(2)!,
      headsign: '',
      mode: TransitMode.fromSiriName(match.group(1)!),
    );
  }

  String? get otpId {
    if (_otpId == null && !checkedOtpId) {
      // TODO
      checkedOtpId = true;
    }
    return _otpId;
  }

  @override
  String toString() {
    return 'TransitRoute(${mode.name} $number to $headsign)';
  }

  @override
  operator ==(other) =>
      other is TransitRoute &&
      other.mode == mode &&
      other.number == number &&
      other.headsign == headsign;

  @override
  int get hashCode => hashValues(mode, number, headsign);
}
