import 'package:intl/intl.dart';

/// Single source of truth for money formatting across both apps.
/// Symbol ₱, locale en_PH, 2 decimals. See spec §1.
class SakaiCurrency {
  SakaiCurrency._();

  static final NumberFormat _fmt = NumberFormat.currency(
    locale: 'en_PH',
    symbol: '₱',
    decimalDigits: 2,
  );

  /// "₱1,234.50" — grouping + 2 decimals, always.
  static String format(num amount) => _fmt.format(amount);

  /// Fare-aware display. A null/missing fare is unknown, not zero —
  /// render it as such, never "₱0.00". A genuine 0 renders "₱0.00".
  static String formatFare(double? fare) =>
      fare == null ? 'Fare pending' : format(fare);
}
