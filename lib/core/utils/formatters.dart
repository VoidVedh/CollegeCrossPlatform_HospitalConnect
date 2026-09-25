import 'package:intl/intl.dart';

/// Formatter utilities for consistent currency, date, and time representations.
class AppFormatters {
  const AppFormatters._();

  static final DateFormat _dateFormat = DateFormat('dd MMM yyyy');
  static final DateFormat _shortDateFormat = DateFormat('dd/MM/yyyy');
  static final DateFormat _timeFormat = DateFormat('hh:mm a');
  static final DateFormat _dateTimeFormat = DateFormat('dd MMM yyyy, hh:mm a');
  static final NumberFormat _currencyFormat = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 0,
  );
  static final NumberFormat _currencyWithDecimals = NumberFormat.currency(
    locale: 'en_IN',
    symbol: '₹',
    decimalDigits: 2,
  );

  /// Formats amount in Indian Rupee format (e.g. ₹800 or ₹1,250.50).
  static String formatCurrency(double amount, {bool showDecimals = false}) {
    if (showDecimals || amount % 1 != 0) {
      return _currencyWithDecimals.format(amount);
    }
    return _currencyFormat.format(amount);
  }

  /// Formats date to standard display format (e.g. 29 Sep 2026).
  static String formatDate(DateTime date) {
    return _dateFormat.format(date);
  }

  /// Formats date to compact short format (e.g. 29/09/2026).
  static String formatDateShort(DateTime date) {
    return _shortDateFormat.format(date);
  }

  /// Formats time to 12-hour format with AM/PM (e.g. 10:30 AM).
  static String formatTime(DateTime date) {
    return _timeFormat.format(date);
  }

  /// Formats combined date and time (e.g. 29 Sep 2026, 10:30 AM).
  static String formatDateTime(DateTime date) {
    return _dateTimeFormat.format(date);
  }

  /// Parses a 12-hour time slot string (e.g. "10:30 AM") into a DateTime on the given [date].
  static DateTime parseTimeSlot(DateTime date, String timeSlot) {
    try {
      final parsedTime = _timeFormat.parse(timeSlot.trim());
      return DateTime(
        date.year,
        date.month,
        date.day,
        parsedTime.hour,
        parsedTime.minute,
      );
    } catch (_) {
      return DateTime(date.year, date.month, date.day);
    }
  }
}
