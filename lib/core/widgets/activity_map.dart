import 'package:cadenceiq_app/core/env/env.dart';
import 'package:cadenceiq_app/core/utils/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class ActivityMap extends StatelessWidget {
  const ActivityMap({super.key, required this.polyline});

  final String polyline;

  @override
  Widget build(BuildContext context) {
    final points = MapUtils().decodePolyline(polyline);

    if (points.isEmpty) {
      return const SizedBox();
    }

    final bounds = LatLngBounds.fromPoints(points);

    return FlutterMap(
      options: MapOptions(
        initialCameraFit: CameraFit.bounds(
          bounds: bounds,
          padding: const EdgeInsets.all(32),
        ),
      ),

      children: [
        TileLayer(
          urlTemplate:
              'https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png?apikey=${Env.mapApiKey}',
          userAgentPackageName: 'com.cadenceiq.cadenceiq_app',
        ),

        PolylineLayer(
          polylines: [
            Polyline(points: points, strokeWidth: 5, color: Colors.blue),
          ],
        ),

        MarkerLayer(
          markers: [
            Marker(
              point: points.first,
              width: 40,
              height: 40,
              child: const Icon(
                Icons.play_circle_fill,
                color: Colors.green,
                size: 28,
              ),
            ),

            Marker(
              point: points.last,
              width: 40,
              height: 40,
              child: const Icon(Icons.flag_circle, color: Colors.red, size: 28),
            ),
          ],
        ),
      ],
    );
  }
}
