import 'package:intl/intl.dart';

class DateFormatter {
  DateFormatter._();

  static final DateFormat _dayFormat = DateFormat('EEE, MMM d');
  static final DateFormat _inputFormat = DateFormat('yyyy-MM-dd');

  static String friendly(DateTime date) => _dayFormat.format(date);

  static String compact(DateTime date) => _inputFormat.format(date);
}
