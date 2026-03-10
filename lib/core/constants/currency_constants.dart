/// Currency Constants for Elajtech App
///
/// Provides a single source of truth for currency labels and codes.
class CurrencyConstants {
  CurrencyConstants._();

  /// Saudi Riyal code
  static const String sar = 'SAR';

  /// Saudi Riyal Arabic label
  static const String sarArabic = 'ريال سعودي';

  /// Egyptian Pound code (for legacy/reference)
  static const String egp = 'EGP';

  /// Egyptian Pound Arabic label (for legacy/reference)
  static const String egpArabic = 'جنية مصري';

  /// The default currency used throughout the app
  static const String defaultCurrency = sar;

  /// The default currency label used in the UI
  static const String defaultCurrencyLabel = sarArabic;
}
