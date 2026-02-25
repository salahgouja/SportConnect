import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/models/models.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';

/// Reusable widget that fetches and displays driver information by ID
/// Follows single source of truth principle - no denormalized data
class DriverInfoWidget extends ConsumerWidget {
  final String driverId;
  final Widget Function(
    BuildContext context,
    String displayName,
    String? photoUrl,
    RatingBreakdown rating,
  )?
  builder;

  const DriverInfoWidget({super.key, required this.driverId, this.builder});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProfileProvider(driverId));

    return userAsync.when(
      data: (user) {
        if (user == null) {
          // Fallback for deleted/missing users
          return builder?.call(
                context,
                'Unknown Driver',
                null,
                RatingBreakdown(),
              ) ??
              const Text('Unknown Driver');
        }

        final displayName = user.displayName;
        final photoUrl = user.photoUrl;
        final rating = user.rating;

        if (builder != null) {
          return builder!(context, displayName, photoUrl, rating);
        }

        // Default simple text display
        return Text(displayName);
      },
      loading: () => const SizedBox(
        width: 16,
        height: 16,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, _) => const Text('Error loading driver'),
    );
  }
}

/// Widget specifically for displaying driver name
class DriverNameWidget extends ConsumerWidget {
  final String driverId;
  final TextStyle? style;

  const DriverNameWidget({super.key, required this.driverId, this.style});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DriverInfoWidget(
      driverId: driverId,
      builder: (context, displayName, _, _) => Text(displayName, style: style),
    );
  }
}

/// Widget for displaying driver avatar
class DriverAvatarWidget extends ConsumerWidget {
  final String driverId;
  final double radius;

  const DriverAvatarWidget({
    super.key,
    required this.driverId,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
class DriverRatingWidget extends ConsumerWidget {
  final String driverId;
  final bool showIcon;
  final TextStyle? style;

  const DriverRatingWidget({
    super.key,
    required this.driverId,
    this.showIcon = true,
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
