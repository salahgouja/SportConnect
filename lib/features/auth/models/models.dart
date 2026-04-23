/// Auth models barrel file
///
/// Import this file to access all auth-related models:
/// ```dart
/// import 'package:sport_connect/features/auth/models/models.dart';
/// ```
///
/// Note: User models have been moved to core/models/user/
/// This file re-exports them for backward compatibility
library;

// Re-export converters from core
export 'package:sport_connect/core/converters/timestamp_converter.dart';
export 'package:sport_connect/core/models/user/achievement.dart';
export 'package:sport_connect/core/models/user/gamification_stats.dart';
export 'package:sport_connect/core/models/user/rating_breakdown.dart';
export 'package:sport_connect/core/models/user/user_enums.dart';
export 'package:sport_connect/core/models/user/user_model.dart';
export 'package:sport_connect/core/models/user/user_preferences.dart';
export 'package:sport_connect/features/auth/models/auth_exception.dart';
export 'package:sport_connect/features/auth/models/social_sign_in_result.dart';
export 'package:sport_connect/features/profile/models/leaderboard_entry.dart';
