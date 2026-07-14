import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:latlong2/latlong.dart';

class MapUtils {
  List<LatLng> decodePolyline(String encoded) {
    final decoded = PolylinePoints.decodePolyline(encoded);

    return decoded.map((e) => LatLng(e.latitude, e.longitude)).toList();
  }

  LatLngBounds calculateBounds(List<LatLng> points) {
    return LatLngBounds.fromPoints(points);
  }
}
