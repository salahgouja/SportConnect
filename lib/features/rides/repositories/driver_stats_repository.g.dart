// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_stats_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(driverStatsRepository)
final driverStatsRepositoryProvider = DriverStatsRepositoryProvider._();

final class DriverStatsRepositoryProvider
    extends
        $FunctionalProvider<
          DriverStatsRepository,
          DriverStatsRepository,
          DriverStatsRepository
        >
    with $Provider<DriverStatsRepository> {
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
  $ProviderElement<DriverStatsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DriverStatsRepository create(Ref ref) {
    return driverStatsRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverStatsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverStatsRepository>(value),
    );
  }
}

String _$driverStatsRepositoryHash() =>
    r'bf9b0d8f7d29d025c1961c82c618522baeb61997';

@ProviderFor(driverStats)
final driverStatsProvider = DriverStatsProvider._();

final class DriverStatsProvider
    extends
        $FunctionalProvider<
          AsyncValue<DriverStats>,
          DriverStats,
          Stream<DriverStats>
        >
    with $FutureModifier<DriverStats>, $StreamProvider<DriverStats> {
  DriverStatsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverStatsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverStatsHash();

  @$internal
  @override
  $StreamProviderElement<DriverStats> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<DriverStats> create(Ref ref) {
    return driverStats(ref);
  }
}

String _$driverStatsHash() => r'2eb778ee2a49c5066daded2513d6676772d82740';

@ProviderFor(pendingRideRequests)
final pendingRideRequestsProvider = PendingRideRequestsProvider._();

final class PendingRideRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideBooking>>,
          List<RideBooking>,
          Stream<List<RideBooking>>
        >
    with
        $FutureModifier<List<RideBooking>>,
        $StreamProvider<List<RideBooking>> {
  PendingRideRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'pendingRideRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$pendingRideRequestsHash();

  @$internal
  @override
  $StreamProviderElement<List<RideBooking>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideBooking>> create(Ref ref) {
    return pendingRideRequests(ref);
  }
}

String _$pendingRideRequestsHash() =>
    r'cbab37c01f2d85e418bc4b1e9b8a49bf9e5279fc';

@ProviderFor(acceptedRideRequests)
final acceptedRideRequestsProvider = AcceptedRideRequestsProvider._();

final class AcceptedRideRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideBooking>>,
          List<RideBooking>,
          Stream<List<RideBooking>>
        >
    with
        $FutureModifier<List<RideBooking>>,
        $StreamProvider<List<RideBooking>> {
  AcceptedRideRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'acceptedRideRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$acceptedRideRequestsHash();

  @$internal
  @override
  $StreamProviderElement<List<RideBooking>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideBooking>> create(Ref ref) {
    return acceptedRideRequests(ref);
  }
}

String _$acceptedRideRequestsHash() =>
    r'b068445d6b2383ec0573231bab5b170938fd73f4';

@ProviderFor(rejectedRideRequests)
final rejectedRideRequestsProvider = RejectedRideRequestsProvider._();

final class RejectedRideRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideBooking>>,
          List<RideBooking>,
          Stream<List<RideBooking>>
        >
    with
        $FutureModifier<List<RideBooking>>,
        $StreamProvider<List<RideBooking>> {
  RejectedRideRequestsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rejectedRideRequestsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rejectedRideRequestsHash();

  @$internal
  @override
  $StreamProviderElement<List<RideBooking>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideBooking>> create(Ref ref) {
    return rejectedRideRequests(ref);
  }
}

String _$rejectedRideRequestsHash() =>
    r'837e9f0452f3ec89e81815a8c21871dc80b6ea18';

@ProviderFor(upcomingDriverRides)
final upcomingDriverRidesProvider = UpcomingDriverRidesProvider._();

final class UpcomingDriverRidesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideModel>>,
          List<RideModel>,
          Stream<List<RideModel>>
        >
    with $FutureModifier<List<RideModel>>, $StreamProvider<List<RideModel>> {
  UpcomingDriverRidesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingDriverRidesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingDriverRidesHash();

  @$internal
  @override
  $StreamProviderElement<List<RideModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideModel>> create(Ref ref) {
    return upcomingDriverRides(ref);
  }
}

String _$upcomingDriverRidesHash() =>
    r'89ed11a6849ea34d8fb80938a21272355057ac2d';

@ProviderFor(earningsTransactions)
final earningsTransactionsProvider = EarningsTransactionsProvider._();

final class EarningsTransactionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EarningsTransaction>>,
          List<EarningsTransaction>,
          Stream<List<EarningsTransaction>>
        >
    with
        $FutureModifier<List<EarningsTransaction>>,
        $StreamProvider<List<EarningsTransaction>> {
  EarningsTransactionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'earningsTransactionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$earningsTransactionsHash();

  @$internal
  @override
  $StreamProviderElement<List<EarningsTransaction>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<EarningsTransaction>> create(Ref ref) {
    return earningsTransactions(ref);
  }
}

String _$earningsTransactionsHash() =>
    r'ecb3ee1bced7940656b3886bf17ea951ebcc304a';
