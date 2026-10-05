import 'package:flutter_test/flutter_test.dart';
import 'package:crypto_app/core/utils/formatters.dart';

void main() {
  group('Formatters', () {
    test('formatCurrency formats various ranges correctly', () {
      expect(Formatters.formatCurrency(null), '-');
      expect(Formatters.formatCurrency(0), '\$0.00');
      expect(Formatters.formatCurrency(84339.01), '\$84,339.01');
      expect(Formatters.formatCurrency(5.24), '\$5.24');
      expect(Formatters.formatCurrency(0.0452), '\$0.0452');
      expect(Formatters.formatCurrency(0.000452), '\$0.000452');
      expect(Formatters.formatCurrency(0.00001234), '\$0.00001234');
      expect(Formatters.formatCurrency(-1234.56), '-\$1,234.56');
    });

    test('formatCompact formats large numbers with metric suffixes', () {
      expect(Formatters.formatCompact(null), '-');
      expect(Formatters.formatCompact(0), '0.00');
      expect(Formatters.formatCompact(500), '500.00');
      expect(Formatters.formatCompact(24510), '24.51K');
      expect(Formatters.formatCompact(2060000), '2.06M');
      expect(Formatters.formatCompact(2060000000), '2.06B');
      expect(Formatters.formatCompact(1500000000000), '1.50T');
      expect(Formatters.formatCompact(-2500000), '-2.50M');
    });

    test('formatPercentage formats signs and decimals', () {
      expect(Formatters.formatPercentage(null), '0.00%');
      expect(Formatters.formatPercentage(1.35), '+1.35%');
      expect(Formatters.formatPercentage(-2.4), '-2.40%');
      expect(Formatters.formatPercentage(0.0), '0.00%');
      expect(Formatters.formatPercentage(1.35, includeSign: false), '1.35%');
    });

    test('formatVolume adds prefix when provided', () {
      expect(Formatters.formatVolume(null), '-');
      expect(Formatters.formatVolume(2060000000, prefix: '\$'), '\$2.06B');
      expect(Formatters.formatVolume(24510), '24.51K');
    });

    test('formatTimestamp handles valid and invalid timestamps', () {
      expect(Formatters.formatTimestamp(null), '-');
      expect(Formatters.formatTimestamp(-1), '-');
      final formatted = Formatters.formatTimestamp(1700000000000);
      expect(formatted, isNotEmpty);
      expect(formatted, isNot('-'));
    });
  });
}
