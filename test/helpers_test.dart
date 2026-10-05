import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_app/core/network/network_exceptions.dart';
import 'package:crypto_app/core/utils/helpers.dart';

void main() {
  group('Helpers', () {
    test('parseDouble parses various types safely', () {
      expect(Helpers.parseDouble(null), 0.0);
      expect(Helpers.parseDouble(42), 42.0);
      expect(Helpers.parseDouble(3.14), 3.14);
      expect(Helpers.parseDouble('84339.01'), 84339.01);
      expect(Helpers.parseDouble('invalid', 5.0), 5.0);
    });

    test('parseInt parses various types safely', () {
      expect(Helpers.parseInt(null), 0);
      expect(Helpers.parseInt(10), 10);
      expect(Helpers.parseInt(15.7), 15);
      expect(Helpers.parseInt('25'), 25);
      expect(Helpers.parseInt('not_an_int', 9), 9);
    });

    test('isPositiveChange returns true for non-negative numbers', () {
      expect(Helpers.isPositiveChange(2.5), isTrue);
      expect(Helpers.isPositiveChange(0.0), isTrue);
      expect(Helpers.isPositiveChange(-1.2), isFalse);
    });

    test('getCoinIconUrl generates correct URL', () {
      expect(
        Helpers.getCoinIconUrl('BTC'),
        'https://assets.coincap.io/assets/icons/btc@2x.png',
      );
    });

    test('getErrorMessage extracts friendly error messages', () {
      expect(
        Helpers.getErrorMessage(const NetworkException(message: 'No internet')),
        'No internet',
      );
      expect(
        Helpers.getErrorMessage(const ApiException(message: 'Rate limit')),
        'Rate limit',
      );
      expect(
        Helpers.getErrorMessage(Exception('Random error')),
        'An unexpected error occurred. Please try again.',
      );
    });
  });
}
