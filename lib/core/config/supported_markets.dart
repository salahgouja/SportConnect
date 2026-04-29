// lib/core/config/supported_markets.dart

abstract final class SupportedMarkets {
  static const franceStripeCountry = 'FR';

  static const String defaultStripeCountry = franceStripeCountry;

  static const addressCountryCodes = 'tn,fr';

  static String stripeCountryFromPhone(String? phone) {
    final normalized = phone?.replaceAll(' ', '').trim();

    if (normalized == null || normalized.isEmpty) {
      return defaultStripeCountry;
    }

    if (normalized.startsWith('+33')) return franceStripeCountry;

    return defaultStripeCountry;
  }
}
