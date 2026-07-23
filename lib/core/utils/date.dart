import 'package:intl/intl.dart';

abstract final class DateHelper {
  static final formatter = DateFormat('yyyy-MM-dd');

  static bool isToday(DateTime date) {
    final now = DateTime.now();

    return formatter.format(date) == formatter.format(now);
  }

  static bool isSameDate(DateTime date1, DateTime date2) {
    return formatter.format(date1) == formatter.format(date2);
  }

  static bool isPastToday(DateTime date) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day); // Midnight today

    return date.isBefore(todayStart);
  }
}
