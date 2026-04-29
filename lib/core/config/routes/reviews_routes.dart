import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sport_connect/core/config/app_routes.dart';
import 'package:sport_connect/core/config/routes/route_config.dart';
import 'package:sport_connect/core/config/routes/route_params.dart';
// Feature imports - Reviews
import 'package:sport_connect/features/reviews/models/review_model.dart';
import 'package:sport_connect/features/reviews/views/reviews_list_screen.dart';
import 'package:sport_connect/features/reviews/views/submit_review_screen.dart';

/// Reviews module routes
class ReviewsRoutes implements RouteConfig {

  @override
  List<RouteBase> getRoutes() {
    return [
      GoRoute(
        path: AppRoutes.submitReview.path,
        name: AppRoutes.submitReview.name,
        pageBuilder: (context, state) {
          final params = state.params;
          final rideId = params.getQueryOrDefault('rideId', '');
          final revieweeId = params.getQueryOrDefault('revieweeId', '');
          final revieweeName = params.getQueryOrDefault('revieweeName', 'User');
          final revieweePhotoUrl = params.getQuery('revieweePhotoUrl');
          final reviewTypeStr = params.getQueryOrDefault(
            'reviewType',
            'driverReview',
          );
          final reviewType = reviewTypeStr == 'passengerReview'
              ? ReviewType.rider
              : ReviewType.driver;

          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: SubmitReviewScreen(
                    rideId: rideId,
                    revieweeId: revieweeId,
                    revieweeName: revieweeName,
                    revieweePhotoUrl: revieweePhotoUrl,
                    reviewType: reviewType,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: SubmitReviewScreen(
                    rideId: rideId,
                    revieweeId: revieweeId,
                    revieweeName: revieweeName,
                    revieweePhotoUrl: revieweePhotoUrl,
                    reviewType: reviewType,
                  ),
                );
        },
      ),
      GoRoute(
        path: AppRoutes.reviewsList.path,
        name: AppRoutes.reviewsList.name,
        pageBuilder: (context, state) {
          final params = state.params;
          final userId = params.getStringOrThrow('userId');
          final userName = params.getQueryOrDefault('userName', 'User');
          final userPhotoUrl = params.getQuery('userPhotoUrl');

          return PlatformInfo.isIOS
              ? CupertinoPage(
                  key: state.pageKey,
                  child: ReviewsListScreen(
                    userId: userId,
                    userName: userName,
                    userPhotoUrl: userPhotoUrl,
                  ),
                )
              : MaterialPage(
                  key: state.pageKey,
                  child: ReviewsListScreen(
                    userId: userId,
                    userName: userName,
                    userPhotoUrl: userPhotoUrl,
                  ),
                );
        },
      ),
    ];
  }
}
