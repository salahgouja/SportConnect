import 'package:sport_connect/core/config/app_config.dart';

enum PremiumPlan { monthly, yearly }

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
        return r'$4.99 / month';
      case PremiumPlan.yearly:
        return r'$49.99 / year';
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

  String get iapProductId {
    switch (this) {
      case PremiumPlan.monthly:
        return AppConfig.premiumMonthlyProductId;
      case PremiumPlan.yearly:
        return AppConfig.premiumYearlyProductId;
    }
  }
}
