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

String _$driverStatsHash() => r'8b75c4bff18085448eb37bb0e7a31ba7f50dc858';

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
    r'766497f0447b8f2bd60b56876b0ff58f56b436ed';

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
    r'c059295ec24ad978801821e07c50fa5f3307f078';

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
    r'1ca2b7bf32922f81e6e14238fff714fbac7e8988';

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
    r'38abf09b754596e28d058e3174cdbcd67ce5d093';

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
    r'2994d8065c1a5de47125a8391fc7019f081222b1';
