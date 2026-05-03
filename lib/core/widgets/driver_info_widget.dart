import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/models/models.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';
import 'package:sport_connect/l10n/generated/app_localizations.dart';

/// Reusable widget that fetches and displays driver information by ID
/// Follows single source of truth principle - no denormalized data
class DriverInfoWidget extends ConsumerWidget {
  const DriverInfoWidget({required this.driverId, super.key, this.builder});
  final String driverId;
  final Widget Function(
    BuildContext context,
    String displayName,
    String? photoUrl,
    RatingBreakdown rating,
  )?
  builder;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider(driverId));

    return userAsync.when(
      data: (user) {
        if (user == null) {
          // Fallback for deleted/missing users
          return builder?.call(
                context,
                AppLocalizations.of(context).unknownDriver,
                null,
                const RatingBreakdown(),
              ) ??
              Text(AppLocalizations.of(context).unknownDriver);
        }

        final displayName = user.username;
        final photoUrl = user.photoUrl;
        final rating = switch (user) {
          final RiderModel rider => rider.rating,
          final DriverModel driver => driver.rating,
          _ => const RatingBreakdown(),
        };

        if (builder != null) {
          return builder!(context, displayName, photoUrl, rating);
        }

        // Default simple text display
        return Text(displayName);
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator.adaptive(strokeWidth: 2),
      ),
      error: (_, _) => Text(AppLocalizations.of(context).errorLoadingDriver),
    );
  }
}

/// Widget specifically for displaying driver name
class DriverNameWidget extends StatelessWidget {
  const DriverNameWidget({required this.driverId, super.key, this.style});
  final String driverId;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return DriverInfoWidget(
      driverId: driverId,
      builder: (context, displayName, _, _) => Text(displayName, style: style),
    );
  }
}

/// Widget for displaying driver avatar
class DriverAvatarWidget extends StatelessWidget {
  const DriverAvatarWidget({
    required this.driverId,
    super.key,
    this.radius = 20,
  });
  final String driverId;
  final double radius;

  @override
  Widget build(BuildContext context) {
    return DriverInfoWidget(
      driverId: driverId,
      builder: (context, displayName, photoUrl, _) => CircleAvatar(
        radius: radius,
        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
        child: photoUrl == null
            ? Text(displayName.isNotEmpty ? displayName[0].toUpperCase() : '?')
            : null,
      ),
    );
  }
}

/// Widget for displaying driver rating
class DriverRatingWidget extends StatelessWidget {
  const DriverRatingWidget({
    required this.driverId,
    super.key,
    this.showIcon = true,
    this.style,
  });
  final String driverId;
  final bool showIcon;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return DriverInfoWidget(
      driverId: driverId,
      builder: (context, _, _, rating) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            const Icon(Icons.star, size: 16, color: Colors.amber),
            const SizedBox(width: 4),
          ],
          Text(rating.average.toStringAsFixed(1), style: style),
        ],
      ),
    );
  }
}
