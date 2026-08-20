import 'package:bijbelquiz_mobile/features/premium/domain/plan_pricing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('parsePriceLabel', () {
    test('reads the common store formats', () {
      expect(parsePriceLabel('€39,99'), closeTo(39.99, 0.001));
      expect(parsePriceLabel('US\$39.99'), closeTo(39.99, 0.001));
      expect(parsePriceLabel('39,99 €'), closeTo(39.99, 0.001));
    });

    test('treats a lone three-digit group as thousands', () {
      expect(parsePriceLabel('€1.199'), closeTo(1199, 0.001));
      expect(parsePriceLabel('€1.199,00'), closeTo(1199, 0.001));
      expect(parsePriceLabel('\$1,199.00'), closeTo(1199, 0.001));
    });

    test('returns null rather than guessing at an unreadable price', () {
      expect(parsePriceLabel('Gratis'), isNull);
      expect(parsePriceLabel(''), isNull);
    });
  });

  group('pricePerWeek', () {
    test('quotes a year in the currency of the label it came from', () {
      // 39.99 / (12 * 4.345) = 0.767
      expect(pricePerWeek('€39,99', months: 12), '€0,77');
      expect(pricePerWeek('US\$39.99', months: 12), 'US\$0.77');
      expect(pricePerWeek('39,99 €', months: 12), '0,77 €');
    });

    test('quotes a month', () {
      // 5.99 / 4.345 = 1.378
      expect(pricePerWeek('€5,99', months: 1), '€1,38');
    });

    test('amortises the one-off plan over the horizon', () {
      // 74.99 / (36 * 4.345) = 0.479
      expect(lifetimePricePerWeek('€74,99'), '€0,48');
      expect(lifetimeHorizonYears, 3);
    });

    test('drops the claim when the price cannot be read', () {
      expect(pricePerWeek('Gratis', months: 12), isNull);
      expect(pricePerWeek('€39,99', months: 0), isNull);
    });
  });

  group('monthlyEquivalentOfYearly', () {
    test('divides by twelve', () {
      expect(monthlyEquivalentOfYearly('€39,99'), '€3,33');
    });
  });

  group('yearlySavingsPercent', () {
    test('compares the year plan against twelve monthly payments', () {
      // 12 * 5.99 = 71.88 against 39.99 is 44% off.
      expect(yearlySavingsPercent('€5,99', '€39,99'), 44);
    });

    test('says nothing when the year plan is not cheaper', () {
      expect(yearlySavingsPercent('€5,99', '€71,88'), isNull);
      expect(yearlySavingsPercent('€5,99', '€99,00'), isNull);
    });

    test('says nothing when a price is unreadable', () {
      expect(yearlySavingsPercent('Gratis', '€39,99'), isNull);
      expect(yearlySavingsPercent('€5,99', 'Gratis'), isNull);
    });
  });
}
