import 'package:cadenceiq/core/env/env.dart';
import 'package:cadenceiq/core/theme/app_colors.dart';
import 'package:cadenceiq/core/utils/map.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';

class ActivityMap extends StatefulWidget {
  const ActivityMap({super.key, required this.polyline});

  final String polyline;

  @override
  State<ActivityMap> createState() => _ActivityMapState();
}

class _ActivityMapState extends State<ActivityMap> {
  bool _tilesReady = false;

  String get _lightTiles =>
      'https://tile.thunderforest.com/cycle/{z}/{x}/{y}.png?apikey=${Env.mapApiKey}';

  String get _darkTiles =>
      'https://tile.thunderforest.com/transport-dark/{z}/{x}/{y}.png?apikey=${Env.mapApiKey}';

  void _markTilesReady() {
    if (_tilesReady || !mounted) return;
    setState(() => _tilesReady = true);
  }

  @override
  Widget build(BuildContext context) {
    final points = MapUtils().decodePolyline(widget.polyline);

    if (points.isEmpty) {
      return const SizedBox();
    }

    final bounds = LatLngBounds.fromPoints(points);
    final isDark = AppColors.isDark(context);
    final mapBackground =
        isDark ? AppColors.darkSurface : AppColors.surfaceVariant;

    return ColoredBox(
      color: mapBackground,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FlutterMap(
            options: MapOptions(
              backgroundColor: mapBackground,
              initialCameraFit: CameraFit.bounds(
                bounds: bounds,
                padding: const EdgeInsets.all(32),
              ),
            ),
            children: [
              TileLayer(
                key: ValueKey(isDark ? 'dark' : 'light'),
                urlTemplate: isDark ? _darkTiles : _lightTiles,
                userAgentPackageName: 'com.cadenceiq.cadenceiq',
                tileBuilder: (context, tileWidget, tile) {
                  if (tile.readyToDisplay) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      _markTilesReady();
                    });
                  }
                  return AnimatedOpacity(
                    opacity: tile.readyToDisplay ? 1 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: tileWidget,
                  );
                },
              ),
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: points,
                    strokeWidth: 5,
                    color: isDark ? AppColors.primaryLight : Colors.blue,
                  ),
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
                    child: const Icon(
                      Icons.flag_circle,
                      color: Colors.red,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
          IgnorePointer(
            child: AnimatedOpacity(
              opacity: _tilesReady ? 0 : 1,
              duration: const Duration(milliseconds: 250),
              child: ColoredBox(
                color: mapBackground,
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 28,
                        height: 28,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: AppColors.textTertiaryOf(context),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Loading map…',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.textTertiaryOf(context),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
