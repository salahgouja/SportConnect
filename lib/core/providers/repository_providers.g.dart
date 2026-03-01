// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Auth repository provider (interface-based).
///
/// Returns [IAuthRepository] for dependency inversion, enabling mocking in
/// tests. All Firebase instances are injected via [firebase_providers.dart].

@ProviderFor(authRepository)
final authRepositoryProvider = AuthRepositoryProvider._();

/// Auth repository provider (interface-based).
///
/// Returns [IAuthRepository] for dependency inversion, enabling mocking in
/// tests. All Firebase instances are injected via [firebase_providers.dart].

final class AuthRepositoryProvider
    extends
        $FunctionalProvider<IAuthRepository, IAuthRepository, IAuthRepository>
    with $Provider<IAuthRepository> {
  /// Auth repository provider (interface-based).
  ///
  /// Returns [IAuthRepository] for dependency inversion, enabling mocking in
  /// tests. All Firebase instances are injected via [firebase_providers.dart].
  AuthRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authRepositoryHash();

  @$internal
  @override
  $ProviderElement<IAuthRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IAuthRepository create(Ref ref) {
    return authRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IAuthRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IAuthRepository>(value),
    );
  }
}

String _$authRepositoryHash() => r'55948b1043c17c4ad2d2953b8ce210a6b6cde753';

/// Chat repository provider (interface-based).

@ProviderFor(chatRepository)
final chatRepositoryProvider = ChatRepositoryProvider._();

/// Chat repository provider (interface-based).

final class ChatRepositoryProvider
    extends
        $FunctionalProvider<IChatRepository, IChatRepository, IChatRepository>
    with $Provider<IChatRepository> {
  /// Chat repository provider (interface-based).
  ChatRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatRepositoryHash();

  @$internal
  @override
  $ProviderElement<IChatRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IChatRepository create(Ref ref) {
    return chatRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IChatRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IChatRepository>(value),
    );
  }
}

String _$chatRepositoryHash() => r'd51649c75f487229a8fc961b67e9b64516104e1e';

/// Notification repository provider (interface-based).

@ProviderFor(notificationRepository)
final notificationRepositoryProvider = NotificationRepositoryProvider._();

/// Notification repository provider (interface-based).

final class NotificationRepositoryProvider
    extends
        $FunctionalProvider<
          INotificationRepository,
          INotificationRepository,
          INotificationRepository
        >
    with $Provider<INotificationRepository> {
  /// Notification repository provider (interface-based).
  NotificationRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationRepositoryHash();

  @$internal
  @override
  $ProviderElement<INotificationRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  INotificationRepository create(Ref ref) {
    return notificationRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(INotificationRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<INotificationRepository>(value),
    );
  }
}

String _$notificationRepositoryHash() =>
    r'9c7b2cd74192a10ca672d9c26fa69add8875c206';

/// User/profile repository provider (interface-based).

@ProviderFor(profileRepository)
final profileRepositoryProvider = ProfileRepositoryProvider._();

/// User/profile repository provider (interface-based).

final class ProfileRepositoryProvider
    extends
        $FunctionalProvider<IUserRepository, IUserRepository, IUserRepository>
    with $Provider<IUserRepository> {
  /// User/profile repository provider (interface-based).
  ProfileRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileRepositoryHash();

  @$internal
  @override
  $ProviderElement<IUserRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IUserRepository create(Ref ref) {
    return profileRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IUserRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IUserRepository>(value),
    );
  }
}

String _$profileRepositoryHash() => r'976b4ba35a3d7abc2bb62bf54d7af63d8279d8fd';

/// Ride repository provider (interface-based).

@ProviderFor(rideRepository)
final rideRepositoryProvider = RideRepositoryProvider._();

/// Ride repository provider (interface-based).

final class RideRepositoryProvider
    extends
        $FunctionalProvider<IRideRepository, IRideRepository, IRideRepository>
    with $Provider<IRideRepository> {
  /// Ride repository provider (interface-based).
  RideRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideRepositoryHash();

  @$internal
  @override
  $ProviderElement<IRideRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IRideRepository create(Ref ref) {
    return rideRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IRideRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IRideRepository>(value),
    );
  }
}

String _$rideRepositoryHash() => r'fb0a8f9ecb2552bbefc72785cc41ba7aceae9c24';

/// Booking repository provider (interface-based).

@ProviderFor(bookingRepository)
final bookingRepositoryProvider = BookingRepositoryProvider._();

/// Booking repository provider (interface-based).

final class BookingRepositoryProvider
    extends
        $FunctionalProvider<
          IBookingRepository,
          IBookingRepository,
          IBookingRepository
        >
    with $Provider<IBookingRepository> {
  /// Booking repository provider (interface-based).
  BookingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'bookingRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$bookingRepositoryHash();

  @$internal
  @override
  $ProviderElement<IBookingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IBookingRepository create(Ref ref) {
    return bookingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IBookingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IBookingRepository>(value),
    );
  }
}

String _$bookingRepositoryHash() => r'caae630ba767218f89c6e327f7a0738b81ebad6a';

/// Payment repository provider (interface-based).

@ProviderFor(paymentRepository)
final paymentRepositoryProvider = PaymentRepositoryProvider._();

/// Payment repository provider (interface-based).

final class PaymentRepositoryProvider
    extends
        $FunctionalProvider<
          IPaymentRepository,
          IPaymentRepository,
          IPaymentRepository
        >
    with $Provider<IPaymentRepository> {
  /// Payment repository provider (interface-based).
  PaymentRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'paymentRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$paymentRepositoryHash();

  @$internal
  @override
  $ProviderElement<IPaymentRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IPaymentRepository create(Ref ref) {
    return paymentRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IPaymentRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IPaymentRepository>(value),
    );
  }
}

String _$paymentRepositoryHash() => r'983723f321ad0ef0fd513ce2113d648ce8a8ad89';

/// Driver stats repository provider (interface-based).

@ProviderFor(driverStatsRepository)
final driverStatsRepositoryProvider = DriverStatsRepositoryProvider._();

/// Driver stats repository provider (interface-based).

final class DriverStatsRepositoryProvider
    extends
        $FunctionalProvider<
          IDriverStatsRepository,
          IDriverStatsRepository,
          IDriverStatsRepository
        >
    with $Provider<IDriverStatsRepository> {
  /// Driver stats repository provider (interface-based).
  DriverStatsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverStatsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverStatsRepositoryHash();

  @$internal
  @override
  $ProviderElement<IDriverStatsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IDriverStatsRepository create(Ref ref) {
    return driverStatsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IDriverStatsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IDriverStatsRepository>(value),
    );
  }
}

String _$driverStatsRepositoryHash() =>
    r'9cb82a69af6523e10f666226569c5595a01f95a4';

/// SharedPreferences instance provider.
///
/// Kept alive so that settings and onboarding providers share the same
/// already-initialised instance throughout the app lifetime.

@ProviderFor(sharedPreferences)
final sharedPreferencesProvider = SharedPreferencesProvider._();

/// SharedPreferences instance provider.
///
/// Kept alive so that settings and onboarding providers share the same
/// already-initialised instance throughout the app lifetime.

final class SharedPreferencesProvider
    extends
        $FunctionalProvider<
          AsyncValue<SharedPreferences>,
          SharedPreferences,
          FutureOr<SharedPreferences>
        >
    with
        $FutureModifier<SharedPreferences>,
        $FutureProvider<SharedPreferences> {
  /// SharedPreferences instance provider.
  ///
  /// Kept alive so that settings and onboarding providers share the same
  /// already-initialised instance throughout the app lifetime.
  SharedPreferencesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'sharedPreferencesProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $FutureProviderElement<SharedPreferences> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SharedPreferences> create(Ref ref) {
    return sharedPreferences(ref);
  }
}

String _$sharedPreferencesHash() => r'48e60558ea6530114ea20ea03e69b9fb339ab129';

/// Settings repository provider.

@ProviderFor(settingsRepository)
final settingsRepositoryProvider = SettingsRepositoryProvider._();

/// Settings repository provider.

final class SettingsRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<SettingsRepository>,
          SettingsRepository,
          FutureOr<SettingsRepository>
        >
    with
        $FutureModifier<SettingsRepository>,
        $FutureProvider<SettingsRepository> {
  /// Settings repository provider.
  SettingsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'settingsRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$settingsRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<SettingsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<SettingsRepository> create(Ref ref) {
    return settingsRepository(ref);
  }
}

String _$settingsRepositoryHash() =>
    r'd54d25ded34b5653a1c965bd3cd0f1a904bd0116';

/// Event repository provider (interface-based).

@ProviderFor(eventRepository)
final eventRepositoryProvider = EventRepositoryProvider._();

/// Event repository provider (interface-based).

final class EventRepositoryProvider
    extends
        $FunctionalProvider<
          IEventRepository,
          IEventRepository,
          IEventRepository
        >
    with $Provider<IEventRepository> {
  /// Event repository provider (interface-based).
  EventRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventRepositoryHash();

  @$internal
  @override
  $ProviderElement<IEventRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IEventRepository create(Ref ref) {
    return eventRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IEventRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IEventRepository>(value),
    );
  }
}

String _$eventRepositoryHash() => r'df64faf7ca38a174d8cf3f120d182b0076f2f74b';

/// Home repository provider (interface-based).

@ProviderFor(homeRepository)
final homeRepositoryProvider = HomeRepositoryProvider._();

/// Home repository provider (interface-based).

final class HomeRepositoryProvider
    extends
        $FunctionalProvider<IHomeRepository, IHomeRepository, IHomeRepository>
    with $Provider<IHomeRepository> {
  /// Home repository provider (interface-based).
  HomeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'homeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$homeRepositoryHash();

  @$internal
  @override
  $ProviderElement<IHomeRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IHomeRepository create(Ref ref) {
    return homeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IHomeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IHomeRepository>(value),
    );
  }
}

String _$homeRepositoryHash() => r'f491d9e14f8df40bdd03313ea2e582f4f030819f';

/// Dispute repository provider (interface-based).

@ProviderFor(disputeRepository)
final disputeRepositoryProvider = DisputeRepositoryProvider._();

/// Dispute repository provider (interface-based).

final class DisputeRepositoryProvider
    extends
        $FunctionalProvider<
          IDisputeRepository,
          IDisputeRepository,
          IDisputeRepository
        >
    with $Provider<IDisputeRepository> {
  /// Dispute repository provider (interface-based).
  DisputeRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'disputeRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$disputeRepositoryHash();

  @$internal
  @override
  $ProviderElement<IDisputeRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IDisputeRepository create(Ref ref) {
    return disputeRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IDisputeRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IDisputeRepository>(value),
    );
  }
}

String _$disputeRepositoryHash() => r'dc5932d348e8114c84e5640d0f4036ac7f7e0de1';

/// Review repository provider (interface-based).

@ProviderFor(reviewRepository)
final reviewRepositoryProvider = ReviewRepositoryProvider._();

/// Review repository provider (interface-based).

final class ReviewRepositoryProvider
    extends
        $FunctionalProvider<
          IReviewRepository,
          IReviewRepository,
          IReviewRepository
        >
    with $Provider<IReviewRepository> {
  /// Review repository provider (interface-based).
  ReviewRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reviewRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reviewRepositoryHash();

  @$internal
  @override
  $ProviderElement<IReviewRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IReviewRepository create(Ref ref) {
    return reviewRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IReviewRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IReviewRepository>(value),
    );
  }
}

String _$reviewRepositoryHash() => r'170f58fea5cc22d4d96f921b0e89ef9997718f42';

/// Support repository provider (interface-based).

@ProviderFor(supportRepository)
final supportRepositoryProvider = SupportRepositoryProvider._();

/// Support repository provider (interface-based).

final class SupportRepositoryProvider
    extends
        $FunctionalProvider<
          ISupportRepository,
          ISupportRepository,
          ISupportRepository
        >
    with $Provider<ISupportRepository> {
  /// Support repository provider (interface-based).
  SupportRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'supportRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$supportRepositoryHash();

  @$internal
  @override
  $ProviderElement<ISupportRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ISupportRepository create(Ref ref) {
    return supportRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ISupportRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ISupportRepository>(value),
    );
  }
}

String _$supportRepositoryHash() => r'edd0c784f7244a5f42e7a9135bf12bcff1cb53c1';

/// Vehicle repository provider (interface-based).

@ProviderFor(vehicleRepository)
final vehicleRepositoryProvider = VehicleRepositoryProvider._();

/// Vehicle repository provider (interface-based).

final class VehicleRepositoryProvider
    extends
        $FunctionalProvider<
          IVehicleRepository,
          IVehicleRepository,
          IVehicleRepository
        >
    with $Provider<IVehicleRepository> {
  /// Vehicle repository provider (interface-based).
  VehicleRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'vehicleRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$vehicleRepositoryHash();

  @$internal
  @override
  $ProviderElement<IVehicleRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  IVehicleRepository create(Ref ref) {
    return vehicleRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IVehicleRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IVehicleRepository>(value),
    );
  }
}

String _$vehicleRepositoryHash() => r'ac07025ef3b54af9c0c4cfd1511c638f183fffd3';

/// Onboarding repository provider (async, SharedPreferences-backed).

@ProviderFor(onboardingRepository)
final onboardingRepositoryProvider = OnboardingRepositoryProvider._();

/// Onboarding repository provider (async, SharedPreferences-backed).

final class OnboardingRepositoryProvider
    extends
        $FunctionalProvider<
          AsyncValue<OnboardingRepository>,
          OnboardingRepository,
          FutureOr<OnboardingRepository>
        >
    with
        $FutureModifier<OnboardingRepository>,
        $FutureProvider<OnboardingRepository> {
  /// Onboarding repository provider (async, SharedPreferences-backed).
  OnboardingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'onboardingRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$onboardingRepositoryHash();

  @$internal
  @override
  $FutureProviderElement<OnboardingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<OnboardingRepository> create(Ref ref) {
    return onboardingRepository(ref);
  }
}

String _$onboardingRepositoryHash() =>
    r'42d7fc634480ec8093c0cc715eb9ce2ff089fc0a';
