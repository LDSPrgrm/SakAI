import 'package:flutter_test/flutter_test.dart';
import 'package:sakai_shared/sakai_shared.dart';

void main() {
  group('SakaiCurrency.format', () {
    test('formats with peso symbol, grouping, 2 decimals', () {
      expect(SakaiCurrency.format(1234.5), '₱1,234.50');
    });
    test('formats zero', () {
      expect(SakaiCurrency.format(0), '₱0.00');
    });
  });

  group('SakaiCurrency.formatFare', () {
    test('null fare is pending, not money', () {
      expect(SakaiCurrency.formatFare(null), 'Fare pending');
    });
    test('genuine zero fare shows ₱0.00', () {
      expect(SakaiCurrency.formatFare(0), '₱0.00');
    });
    test('present fare formats as money', () {
      expect(SakaiCurrency.formatFare(1234.5), '₱1,234.50');
    });
  });
}
