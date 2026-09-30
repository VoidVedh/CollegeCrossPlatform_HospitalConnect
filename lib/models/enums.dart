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
  cancelled,
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

/// Sorting criteria for doctor catalog.
enum DoctorSortOption {
  rating,
  feeLowToHigh,
  feeHighToLow,
  experience;

  String get displayName {
    switch (this) {
      case DoctorSortOption.rating:
        return 'Highest Rated';
      case DoctorSortOption.feeLowToHigh:
        return 'Fee: Low to High';
      case DoctorSortOption.feeHighToLow:
        return 'Fee: High to Low';
      case DoctorSortOption.experience:
        return 'Most Experienced';
    }
  }
}
