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

  /// Attempts to parse a 12-hour time slot string (e.g. "10:30 AM") into a DateTime on the given [date].
  /// Returns null if parsing fails.
  static DateTime? tryParseTimeSlot(DateTime date, String timeSlot) {
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
      return null;
    }
  }

  /// Parses a 12-hour time slot string (e.g. "10:30 AM") into a DateTime on the given [date].
  /// Throws [FormatException] if the slot string cannot be parsed. Never silently returns midnight.
  static DateTime parseTimeSlot(DateTime date, String timeSlot) {
    final parsed = tryParseTimeSlot(date, timeSlot);
    if (parsed == null) {
      throw FormatException('Invalid time slot format: "$timeSlot". Expected format e.g. 10:30 AM');
    }
    return parsed;
  }

  /// Formats next available slot (e.g. "Today, 10:30 AM", "Tomorrow, 02:00 PM", or "02 Oct, 11:00 AM").
  static String formatNextSlot(DateTime? slot) {
    if (slot == null) return 'No upcoming slots';
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final slotDate = DateTime(slot.year, slot.month, slot.day);
    final diffDays = slotDate.difference(today).inDays;
    final timeStr = formatTime(slot);

    if (diffDays == 0) {
      return 'Today, $timeStr';
    } else if (diffDays == 1) {
      return 'Tomorrow, $timeStr';
    } else {
      return '${DateFormat('dd MMM').format(slot)}, $timeStr';
    }
  }
}
