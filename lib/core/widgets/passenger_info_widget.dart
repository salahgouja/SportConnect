import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sport_connect/core/models/user/user_model.dart';
import 'package:sport_connect/core/theme/app_colors.dart';
import 'package:sport_connect/features/profile/view_models/profile_view_model.dart';

/// Base widget that fetches passenger data and provides it to a builder
/// Following database normalization - no denormalized passenger data in models
class PassengerInfoWidget extends ConsumerWidget {
  final String passengerId;
  final Widget Function(BuildContext context, UserModel passenger) builder;

  const PassengerInfoWidget({
    super.key,
    required this.passengerId,
    required this.builder,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passengerAsync = ref.watch(userProfileProvider(passengerId));

    return passengerAsync.when(
      data: (passenger) {
        if (passenger == null) {
          return const Text('Passenger not found');
        }
        return builder(context, passenger);
      },
      loading: () => const CircularProgressIndicator.adaptive(),
      error: (_, _) => const Text('Error loading passenger'),
    );
  }
}

/// Displays passenger name with loading/error states
class PassengerNameWidget extends ConsumerWidget {
  final String passengerId;
  final TextStyle? style;
  final int? maxLines;
  final TextOverflow? overflow;

  const PassengerNameWidget({
    super.key,
    required this.passengerId,
    this.style,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passengerAsync = ref.watch(userProfileProvider(passengerId));

    return passengerAsync.when(
      data: (passenger) => Text(
        passenger?.displayName ?? 'Unknown',
        style: style,
        maxLines: maxLines,
        overflow: overflow,
      ),
      loading: () => Text(
        'Loading...',
        style: style?.copyWith(color: AppColors.textTertiary),
        maxLines: maxLines,
        overflow: overflow,
      ),
      error: (_, _) => Text(
        'Unknown',
        style: style?.copyWith(color: AppColors.error),
        maxLines: maxLines,
        overflow: overflow,
      ),
    );
  }
}

/// Displays passenger avatar with loading/error states
class PassengerAvatarWidget extends ConsumerWidget {
  final String passengerId;
  final double radius;

  const PassengerAvatarWidget({
    super.key,
    required this.passengerId,
    this.radius = 20,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passengerAsync = ref.watch(userProfileProvider(passengerId));

    return passengerAsync.when(
      data: (passenger) {
        final photoUrl = passenger?.photoUrl;
        final displayName = passenger?.displayName ?? 'Unknown';

        return CircleAvatar(
          radius: radius,
          backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
          backgroundColor: AppColors.primarySurface,
          child: photoUrl == null
              ? Text(
                  displayName.isNotEmpty ? displayName[0] : '?',
                  style: TextStyle(
                    fontSize: radius * 0.7,
                    color: AppColors.primary,
                  ),
                )
              : null,
        );
      },
      loading: () => CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.surface,
        child: SizedBox(
          width: radius * 0.7,
          height: radius * 0.7,
          child: const CircularProgressIndicator.adaptive(strokeWidth: 2),
        ),
      ),
      error: (_, _) => CircleAvatar(
        radius: radius,
        backgroundColor: AppColors.error.withOpacity(0.1),
        child: Icon(Icons.error, size: radius * 0.7, color: AppColors.error),
      ),
    );
  }
}

/// Displays passenger phone number with loading/error states
class PassengerPhoneWidget extends ConsumerWidget {
  final String passengerId;
  final TextStyle? style;

  const PassengerPhoneWidget({
    super.key,
    required this.passengerId,
    this.style,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final passengerAsync = ref.watch(userProfileProvider(passengerId));

    return passengerAsync.when(
      data: (passenger) =>
          Text(passenger?.phoneNumber ?? 'No phone', style: style),
      loading: () => Text(
        'Loading...',
        style: style?.copyWith(color: AppColors.textTertiary),
      ),
      error: (_, _) =>
          Text('N/A', style: style?.copyWith(color: AppColors.error)),
    );
  }
}
