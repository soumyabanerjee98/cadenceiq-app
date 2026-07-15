import 'package:intl/intl.dart';

abstract final class Formatters {
  static final _date = DateFormat('MMM d, yyyy');
  static final _shortDate = DateFormat('MMM d');
  static final _time = DateFormat('h:mm a');

  static String date(DateTime dt) => _date.format(dt);
  static String shortDate(DateTime dt) => _shortDate.format(dt);
  static String time(DateTime dt) => _time.format(dt);

  static String duration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    final s = d.inSeconds.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    if (m > 0) return '${m}m ${s}s';
    return '${s}s';
  }

  static String distanceKm(double km, {bool imperial = false}) {
    if (imperial) {
      final miles = km * 0.621371;
      return '${miles.toStringAsFixed(1)} mi';
    }
    return '${km.toStringAsFixed(1)} km';
  }

  static String speedKmh(double kmh, {bool imperial = false}) {
    if (imperial) {
      final mph = kmh * 0.621371;
      return '${mph.toStringAsFixed(1)} mph';
    }
    return '${kmh.toStringAsFixed(1)} km/h';
  }

  static String elevationM(num m, {bool imperial = false}) {
    if (imperial) {
      final ft = m * 3.28084;
      return '${ft.round()} ft';
    }
    return '${m.round()} m';
  }

  static String load(num load) => load.toStringAsFixed(0);
  static String percent(double p) => '${(p * 100).round()}%';
  static String watts(num w) => '${w.round()} W';
  static String bpm(int? hr) => '${hr ?? "-"} bpm';
  static String calories(int c) => '$c kcal';
}
