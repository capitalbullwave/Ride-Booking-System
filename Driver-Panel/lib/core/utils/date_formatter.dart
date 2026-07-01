import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final DateFormat _monthYearFormat = DateFormat('MMM yyyy');
  static final DateFormat _apiDateFormat = DateFormat('yyyy-MM-dd');

  /// Normalizes picker or typed dates to `YYYY-MM-DD` for API payloads.
  static String? toApiDate(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;

    final value = raw.trim();
    if (RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(value)) {
      return value;
    }

    final match =
        RegExp(r'^(\d{1,2})[/.-](\d{1,2})[/.-](\d{4})$').firstMatch(value);
    if (match != null) {
      final day = int.parse(match.group(1)!);
      final month = int.parse(match.group(2)!);
      final year = int.parse(match.group(3)!);
      return _apiDateFormat.format(DateTime(year, month, day));
    }

    try {
      return _apiDateFormat.format(DateTime.parse(value));
    } catch (_) {
      return null;
    }
  }

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
