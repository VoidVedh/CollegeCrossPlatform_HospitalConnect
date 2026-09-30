/// Base exception class for all domain and application errors.
class AppException implements Exception {
  const AppException(this.message, [this.details]);

  final String message;
  final dynamic details;

  /// Clean, user-friendly presentation message without technical traces.
  String get userFriendlyMessage => message;

  @override
  String toString() => message;
}

/// Thrown when attempting to book a slot that has already been reserved.
class SlotUnavailableException extends AppException {
  const SlotUnavailableException([
    super.message = 'The requested time slot is no longer available.',
    super.details,
  ]);
}

/// Thrown when attempting to book a time slot in the past.
class PastSlotBookingException extends AppException {
  const PastSlotBookingException([
    super.message = 'Selected time slot has already passed for today.',
    super.details,
  ]);
}

/// Thrown when attempting an action that creates a duplicate booking.
class DoubleBookingException extends SlotUnavailableException {
  const DoubleBookingException([
    super.message =
        'This doctor already has a confirmed booking for the selected slot.',
    super.details,
  ]);
}

/// Thrown when an entity is not found in repository.
class NotFoundException extends AppException {
  const NotFoundException([
    super.message = 'The requested entity could not be found.',
    super.details,
  ]);
}

/// Thrown when a payment attempt fails or is declined.
class PaymentFailedException extends AppException {
  const PaymentFailedException([
    super.message = 'Payment transaction failed. Please try again.',
    super.details,
  ]);
}

/// Thrown when business validation fails.
class ValidationException extends AppException {
  const ValidationException([
    super.message = 'Invalid input parameters provided.',
    super.details,
  ]);
}

/// Thrown when repository/persistence layer encounters an error.
class RepositoryException extends AppException {
  const RepositoryException([
    super.message = 'A data repository operation failed.',
    super.details,
  ]);
}
