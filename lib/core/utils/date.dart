import 'package:intl/intl.dart';

abstract final class DateHelper {
  static bool isToday(DateTime date) {
    final formatter = DateFormat('yyyy-MM-dd');
    final now = DateTime.now();

    return formatter.format(date) == formatter.format(now);
  }

  static bool isPastToday(DateTime date) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day); // Midnight today

    return date.isBefore(todayStart);
  }
}
