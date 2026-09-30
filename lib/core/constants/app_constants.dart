/// Application-wide constants for billing, business rules, and scheduling.
class AppConstants {
  const AppConstants._();

  /// Standard Goods and Services Tax (GST) rate applied to hospital consultations.
  static const double gstTaxRate = 0.18;

  /// Working hours configuration for specialist doctor scheduling.
  static const int workdayStartHour = 9;
  static const int workdayStartMinute = 0;
  static const int workdayEndHour = 17;
  static const int workdayEndMinute = 30;
  static const int slotDurationMinutes = 30;

  /// Lunch gap during which appointments cannot be booked.
  static const int lunchBreakStartHour = 13;
  static const int lunchBreakEndHour = 14;

  /// Standard default consultation fee when unspecified.
  static const double defaultConsultationFee = 500.0;
}
