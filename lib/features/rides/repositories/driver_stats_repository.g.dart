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
          IDriverStatsRepository,
          IDriverStatsRepository,
          IDriverStatsRepository
        >
    with $Provider<IDriverStatsRepository> {
  DriverStatsRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverStatsRepositoryProvider',
        isAutoDispose: true,
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
    r'2455a9ea7422598ca46a91e3500984ef1eaaad80';

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

String _$driverStatsHash() => r'fcb3a7aecfbc2da6a9e6b1ae8a6906649d1a36d6';

@ProviderFor(pendingRideRequests)
final pendingRideRequestsProvider = PendingRideRequestsProvider._();

final class PendingRideRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideRequestModel>>,
          List<RideRequestModel>,
          Stream<List<RideRequestModel>>
        >
    with
        $FutureModifier<List<RideRequestModel>>,
        $StreamProvider<List<RideRequestModel>> {
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
  $StreamProviderElement<List<RideRequestModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideRequestModel>> create(Ref ref) {
    return pendingRideRequests(ref);
  }
}

String _$pendingRideRequestsHash() =>
    r'77aefe6b60673c0853b7063520fcb8fbed6bb03b';

@ProviderFor(acceptedRideRequests)
final acceptedRideRequestsProvider = AcceptedRideRequestsProvider._();

final class AcceptedRideRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideRequestModel>>,
          List<RideRequestModel>,
          Stream<List<RideRequestModel>>
        >
    with
        $FutureModifier<List<RideRequestModel>>,
        $StreamProvider<List<RideRequestModel>> {
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
  $StreamProviderElement<List<RideRequestModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideRequestModel>> create(Ref ref) {
    return acceptedRideRequests(ref);
  }
}

String _$acceptedRideRequestsHash() =>
    r'e6a883fedd14bdcbbaaae32413dfde4daf5d44e2';

@ProviderFor(rejectedRideRequests)
final rejectedRideRequestsProvider = RejectedRideRequestsProvider._();

final class RejectedRideRequestsProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideRequestModel>>,
          List<RideRequestModel>,
          Stream<List<RideRequestModel>>
        >
    with
        $FutureModifier<List<RideRequestModel>>,
        $StreamProvider<List<RideRequestModel>> {
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
  $StreamProviderElement<List<RideRequestModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideRequestModel>> create(Ref ref) {
    return rejectedRideRequests(ref);
  }
}

String _$rejectedRideRequestsHash() =>
    r'23599351633ece364e914e7607d66589586bd210';

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
