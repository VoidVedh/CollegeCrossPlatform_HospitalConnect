import 'package:flutter_test/flutter_test.dart';
import 'package:hospital_connect/core/utils/validators.dart';

void main() {
  group('AppValidators tests', () {
    test('validateName accepts valid letters and spaces, rejects short/symbols', () {
      expect(AppValidators.validateName('Aditya Sharma'), isNull);
      expect(AppValidators.validateName('A'), isNotNull);
      expect(AppValidators.validateName(''), isNotNull);
      expect(AppValidators.validateName('Aditya123'), isNotNull);
    });

    test('validateAge verifies range 1 to 120', () {
      expect(AppValidators.validateAge('25'), isNull);
      expect(AppValidators.validateAge('0'), isNotNull);
      expect(AppValidators.validateAge('121'), isNotNull);
      expect(AppValidators.validateAge('abc'), isNotNull);
    });

    test('validatePhone requires 10 digits starting with 6-9', () {
      expect(AppValidators.validatePhone('9876543210'), isNull);
      expect(AppValidators.validatePhone('1234567890'), isNotNull);
      expect(AppValidators.validatePhone('98765'), isNotNull);
    });

    test('validateSymptoms requires at least 10 chars', () {
      expect(AppValidators.validateSymptoms('Severe chest pain and cold'), isNull);
      expect(AppValidators.validateSymptoms('Fever'), isNotNull);
      expect(AppValidators.validateSymptoms(''), isNotNull);
    });

    test('validateUpiId requires valid @ format', () {
      expect(AppValidators.validateUpiId('user@okhdfcbank'), isNull);
      expect(AppValidators.validateUpiId('invalidupi'), isNotNull);
    });

    test('validateCardNumber requires 16 digits', () {
      expect(AppValidators.validateCardNumber('4111 2222 3333 4444'), isNull);
      expect(AppValidators.validateCardNumber('4111222233334444'), isNull);
      expect(AppValidators.validateCardNumber('1234'), isNotNull);
    });
  });
}
