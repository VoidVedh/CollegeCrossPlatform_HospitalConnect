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
  netBanking;

  String get displayName {
    switch (this) {
      case PaymentMethodType.upi:
        return 'UPI';
      case PaymentMethodType.card:
        return 'Credit / Debit Card';
      case PaymentMethodType.netBanking:
        return 'Net Banking';
    }
  }
}
