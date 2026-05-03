import 'package:flutter/foundation.dart';
import 'package:sport_connect/core/config/app_config.dart';

enum PremiumPlan {
  monthly,
  yearly,
}

extension PremiumPlanX on PremiumPlan {
  String get title {
    switch (this) {
      case PremiumPlan.monthly:
        return 'Monthly';
      case PremiumPlan.yearly:
        return 'Yearly';
    }
  }

  String get priceLabel {
    switch (this) {
      case PremiumPlan.monthly:
        return '€4.99 / month';
      case PremiumPlan.yearly:
        return '€49.99 / year';
    }
  }

  String get helperText {
    switch (this) {
      case PremiumPlan.monthly:
        return 'Cancel anytime';
      case PremiumPlan.yearly:
        return 'Save about 16% compared to monthly';
    }
  }

  /// Store product ID used for querying in_app_purchase.
  ///
  /// Android:
  /// Query the Google Play subscription product:
  /// sportconnect_premium
  ///
  /// iOS:
  /// Query the App Store product:
  /// sportconnect_premium_monthly / sportconnect_premium_yearly
  String get iapProductId {
    if (kIsWeb) {
      return AppConfig.premiumSubscriptionProductId;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AppConfig.premiumSubscriptionProductId;

      case TargetPlatform.iOS:
        return iosProductId;

      default:
        return AppConfig.premiumSubscriptionProductId;
    }
  }

  /// Google Play subscription product ID.
  String get googlePlayProductId {
    return AppConfig.premiumSubscriptionProductId;
  }

  /// Google Play base plan ID.
  ///
  /// This is NOT queried as a product.
  /// It is used after querying sportconnect_premium to choose monthly/yearly.
  String get googlePlayBasePlanId {
    switch (this) {
      case PremiumPlan.monthly:
        return AppConfig.premiumMonthlyBasePlanId;
      case PremiumPlan.yearly:
        return AppConfig.premiumYearlyBasePlanId;
    }
  }

  /// App Store product ID.
  String get iosProductId {
    switch (this) {
      case PremiumPlan.monthly:
        return AppConfig.iosPremiumMonthlyProductId;
      case PremiumPlan.yearly:
        return AppConfig.iosPremiumYearlyProductId;
    }
  }
}
