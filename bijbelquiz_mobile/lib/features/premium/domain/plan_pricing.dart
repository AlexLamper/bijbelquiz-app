/// The derived numbers a paywall quotes on top of the store's own price.
///
/// Three plans that bill on three different rhythms - a month, a year, once -
/// cannot be compared at a glance. The week can: it is the smallest honest
/// common unit, and the one a reader already prices small things in. So every
/// plan leads with its per-week equivalent and states the real charge, in the
/// period it is actually taken, directly next to it.
///
/// This is the Dart half of `src/lib/premium-benefits.ts` in the web repo:
/// same 4.345 weeks per month, same three-year horizon for the one-off plan,
/// same refusal to print a derived number that cannot be computed. Change one
/// and change the other, or the two clients start quoting different prices for
/// the same product.
///
/// Everything here works off the store's localized `priceString` ("€39,99",
/// "US$39.99", "39,99 €"), because that string is the only price the store
/// guarantees is correct for this buyer. Derived values are printed with the
/// currency and decimal separator lifted off that same string, so a euro price
/// never produces a dollar claim.
library;

/// Average number of weeks in a month; the store convention for quoting a
/// per-week equivalent of a longer billing period.
const double _weeksPerMonth = 4.345;

/// Years a one-off "levenslang" purchase is amortised over when quoted per
/// week.
///
/// Deliberately conservative: three years undersells a lifetime licence rather
/// than making a promise about how long the product will exist.
const int lifetimeHorizonYears = 3;

/// Matches the number inside a localized price, including any grouping
/// separators: `39,99`, `39.99`, `1.199,00`.
final RegExp _numberPattern = RegExp(r'\d[\d.,\s]*\d|\d');

/// Read the amount out of a localized store price.
///
/// Returns null when the string carries no usable number, which is the signal
/// for callers to drop the derived claim entirely instead of guessing at one.
double? parsePriceLabel(String label) {
  final match = _numberPattern.firstMatch(label);
  if (match == null) return null;

  final value = double.tryParse(_normalizeNumber(match.group(0)!));
  return (value != null && value > 0) ? value : null;
}

/// Per-week equivalent of a price that covers [months] months, formatted like
/// the label it was derived from.
String? pricePerWeek(String label, {required int months}) {
  final amount = parsePriceLabel(label);
  if (amount == null || months <= 0) return null;

  return _formatLike(label, amount / (months * _weeksPerMonth));
}

/// Per-week equivalent of the one-off lifetime price, over
/// [lifetimeHorizonYears].
String? lifetimePricePerWeek(String label) =>
    pricePerWeek(label, months: lifetimeHorizonYears * 12);

/// Monthly equivalent of a yearly price, e.g. "€3,33".
String? monthlyEquivalentOfYearly(String yearlyLabel) {
  final yearly = parsePriceLabel(yearlyLabel);
  if (yearly == null) return null;

  return _formatLike(yearlyLabel, yearly / 12);
}

/// What the yearly plan saves against twelve monthly payments, as a whole
/// percentage.
///
/// Null when either price is unreadable, or when the year plan is not actually
/// cheaper - a "Bespaar 0%" badge is worse than no badge.
int? yearlySavingsPercent(String monthlyLabel, String yearlyLabel) {
  final monthly = parsePriceLabel(monthlyLabel);
  final yearly = parsePriceLabel(yearlyLabel);
  if (monthly == null || yearly == null) return null;

  final twelveMonths = monthly * 12;
  if (yearly >= twelveMonths) return null;

  return (((twelveMonths - yearly) / twelveMonths) * 100).round();
}

/// Turn the digits of a localized number into something `double.tryParse` can
/// read: grouping separators dropped, the decimal one turned into a point.
String _normalizeNumber(String raw) {
  final digits = _stripSpaces(raw);
  final decimalAt = _decimalPointIndex(digits);
  if (decimalAt < 0) return digits.replaceAll(RegExp(r'[.,]'), '');

  final whole = digits.substring(0, decimalAt).replaceAll(RegExp(r'[.,]'), '');
  return '$whole.${digits.substring(decimalAt + 1)}';
}

/// Store prices space their thousands in some locales ("1 199,00"), including
/// with a non-breaking space - which Dart's `\s` covers.
String _stripSpaces(String raw) => raw.replaceAll(RegExp(r'\s'), '');

/// Index of the decimal point inside a digit run, or -1 when every separator
/// in it groups thousands.
///
/// With both separators present the last one is the decimal point and the
/// other groups ("1.199,00" and "1,199.00" are the same amount). A lone
/// separator followed by exactly three digits groups: "1.199" is one thousand
/// one hundred ninety-nine, not 1.199 euro.
int _decimalPointIndex(String digits) {
  final lastComma = digits.lastIndexOf(',');
  final lastDot = digits.lastIndexOf('.');

  if (lastComma >= 0 && lastDot >= 0) {
    return lastComma > lastDot ? lastComma : lastDot;
  }

  final separatorAt = lastComma >= 0 ? lastComma : lastDot;
  if (separatorAt < 0) return -1;

  return digits.length - separatorAt - 1 == 3 ? -1 : separatorAt;
}

/// Print [value] with the currency affix and decimal separator of [source].
///
/// The store owns the formatting of a price, so a derived figure copies it
/// rather than inventing a euro sign of its own.
String _formatLike(String source, double value) {
  final match = _numberPattern.firstMatch(source);
  if (match == null) return value.toStringAsFixed(2);

  final digits = _stripSpaces(match.group(0)!);
  final decimalAt = _decimalPointIndex(digits);
  final separator = decimalAt < 0 ? ',' : digits[decimalAt];
  final amount = value.toStringAsFixed(2).replaceAll('.', separator);

  return '${source.substring(0, match.start)}$amount'
      '${source.substring(match.end)}';
}
