// Common domain status and method enums for HospitalConnect.

/// Status of an appointment.
enum AppointmentStatus {
  upcoming,
  completed,
  cancelled,
}

/// Status of a billing invoice.
enum BillStatus {
  unpaid,
  paid,
  pending,
}

/// Payment method types supported by the payment gateway.
enum PaymentMethodType {
  upi,
  card,
  netBanking,
}
