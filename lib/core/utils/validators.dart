/// Form and input validation utilities for HospitalConnect.
class AppValidators {
  const AppValidators._();

  static final RegExp _nameRegex = RegExp(r'^[a-zA-Z\s]+$');
  static final RegExp _phoneRegex = RegExp(r'^[6-9]\d{9}$');
  static final RegExp _upiRegex = RegExp(r'^[\w.-]+@[\w.-]+$');
  static final RegExp _cardRegex = RegExp(r'^\d{16}$');
  static final RegExp _cvvRegex = RegExp(r'^\d{3}$');

  /// Validates patient name: required, letters/spaces, min 2 chars.
  static String? validateName(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Patient name is required';
    }
    if (text.length < 2) {
      return 'Name must be at least 2 characters';
    }
    if (!_nameRegex.hasMatch(text)) {
      return 'Name can only contain letters and spaces';
    }
    return null;
  }

  /// Validates patient age: required, between 1 and 120.
  static String? validateAge(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Age is required';
    }
    final age = int.tryParse(text);
    if (age == null || age < 1 || age > 120) {
      return 'Please enter a valid age (1-120)';
    }
    return null;
  }

  /// Validates Indian 10-digit phone number starting with 6, 7, 8, or 9.
  static String? validatePhone(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Phone number is required';
    }
    if (!_phoneRegex.hasMatch(text)) {
      return 'Enter a valid 10-digit mobile number';
    }
    return null;
  }

  /// Validates symptoms note: required, min 10 chars.
  static String? validateSymptoms(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Please describe symptoms or reason for visit';
    }
    if (text.length < 10) {
      return 'Symptoms note must be at least 10 characters';
    }
    return null;
  }

  /// Validates UPI ID (e.g. username@okhdfcbank).
  static String? validateUpiId(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'UPI ID is required';
    }
    if (!_upiRegex.hasMatch(text)) {
      return 'Enter a valid UPI ID (e.g. name@okhdfcbank)';
    }
    return null;
  }

  /// Validates 16-digit debit/credit card number.
  static String? validateCardNumber(String? value) {
    final text = value?.replaceAll(RegExp(r'\s+'), '') ?? '';
    if (text.isEmpty) {
      return 'Card number is required';
    }
    if (!_cardRegex.hasMatch(text)) {
      return 'Card number must be 16 digits';
    }
    return null;
  }

  /// Validates card expiration in MM/YY format.
  static String? validateCardExpiry(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'Expiry date is required';
    }
    final parts = text.split('/');
    if (parts.length != 2) {
      return 'Use MM/YY format';
    }
    final month = int.tryParse(parts[0]);
    final year = int.tryParse(parts[1]);
    if (month == null || month < 1 || month > 12) {
      return 'Invalid month (01-12)';
    }
    if (year == null || year < 24) {
      return 'Card has expired';
    }
    return null;
  }

  /// Validates 3-digit card CVV code.
  static String? validateCvv(String? value) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return 'CVV required';
    }
    if (!_cvvRegex.hasMatch(text)) {
      return 'CVV must be 3 digits';
    }
    return null;
  }
}
