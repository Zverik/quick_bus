import 'dart:math' as math;
import 'package:latlong2/latlong.dart';
import 'package:quick_bus/helpers/equirectangular.dart';

class PathUtils {
  double distance(LatLng point, Path path) {
    return DistanceEquirectangular()(point, closestPoint(path, point));
  }

  LatLng closestPoint(Path path, LatLng point) {
    if (path.nrOfCoordinates < 2) return path.first;
    final coords =
        path.coordinates.map((p) => project(p)).toList(growable: false);
    final p = project(point);
    double minDist = 1000.0;
    LatLng closest = path.first;
    for (int i = 0; i < coords.length - 1; i++) {
      final a = coords[i];
      final b = coords[i + 1];
      final abDist =
          (b[0] - a[0]) * (b[0] - a[0]) + (b[1] - a[1]) * (b[1] - a[1]);
      final abpDot =
          (p[0] - a[0]) * (b[0] - a[0]) + (p[1] - a[1]) * (b[1] - a[1]);
      var t = abDist == 0 ? 0 : abpDot / abDist;
      if (t < 0)
        t = 0;
      else if (t > 1) t = 1;
      final m = [a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t];
      final dist =
          (m[0] - p[0]) * (m[0] - p[0]) + (m[1] - p[1]) * (m[1] - p[1]);
      if (dist < minDist) {
        minDist = dist;
        if (t <= 0)
          closest = path[i];
        else if (t >= 1)
          closest = path[i + 1];
        else
          closest = LatLng(
            path[i].latitude + (path[i + 1].latitude - path[i].latitude) * t,
            path[i].longitude + (path[i + 1].longitude - path[i].longitude) * t,
          );
      }
    }
    return closest;
  }

  List<double> project(LatLng point) {
    final y = point.latitudeInRad;
    final x = point.longitudeInRad * math.cos(y);
    return [x, y];
  }

  List<Path?> splitAt(Path path, LatLng point) {
    // TODO: someday write a proper algorithm
    return splitAtCrude(path, point);
  }

  List<Path?> splitAtCrude(Path path, LatLng point) {
    var dist = DistanceEquirectangular();
    LatLng closestPoint = path.coordinates
        .reduce((a, b) => dist(a, point) < dist(b, point) ? a : b);
    int cutIndex = path.coordinates.indexOf(closestPoint);
    return [
      cutIndex == 0
          ? null
          : Path.from(path.coordinates.sublist(0, cutIndex + 1)),
      cutIndex == path.coordinates.length
          ? path
          : Path.from(path.coordinates.sublist(cutIndex)),
    ];
  }

  double fastLength(Path path) {
    double length = 0.0;
    if (path.coordinates.length < 2)
      return length;
    var dist = DistanceEquirectangular();
    for (var i = 0; i < path.coordinates.length - 1; i++) {
      length += dist(path.coordinates[i], path.coordinates[i+1]);
    }
    return length;
  }
}
