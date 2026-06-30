import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy');

  static String date(DateTime date) => _dateFormat.format(date);

  static String time(DateTime date) => _timeFormat.format(date);

  static String dateTime(DateTime date) => _dateTimeFormat.format(date);

  static String monthYear(DateTime date) => _monthYearFormat.format(date);

  static String currency(double amount, {String symbol = '₹'}) {
    return '$symbol${amount.toStringAsFixed(2)}';
  }

  static String duration(int minutes) {
    if (minutes < 60) return '${minutes}m';
    final hours = minutes ~/ 60;
    final mins = minutes % 60;
    return mins > 0 ? '${hours}h ${mins}m' : '${hours}h';
  }

  static String distance(double km) => '${km.toStringAsFixed(1)} km';
}
