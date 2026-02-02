// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ride Form View Model

@ProviderFor(RideFormViewModel)
final rideFormViewModelProvider = RideFormViewModelProvider._();

/// Ride Form View Model
final class RideFormViewModelProvider
    extends $NotifierProvider<RideFormViewModel, RideFormState> {
  /// Ride Form View Model
  RideFormViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideFormViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideFormViewModelHash();

  @$internal
  @override
  RideFormViewModel create() => RideFormViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RideFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RideFormState>(value),
    );
  }
}

String _$rideFormViewModelHash() => r'8a76bb64b2ab6e480bd3a52e1613f70900f9c3ee';

/// Ride Form View Model

abstract class _$RideFormViewModel extends $Notifier<RideFormState> {
  RideFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RideFormState, RideFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RideFormState, RideFormState>,
              RideFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Ride Search View Model

@ProviderFor(RideSearchViewModel)
final rideSearchViewModelProvider = RideSearchViewModelProvider._();

/// Ride Search View Model
final class RideSearchViewModelProvider
    extends $NotifierProvider<RideSearchViewModel, RideSearchState> {
  /// Ride Search View Model
  RideSearchViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideSearchViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideSearchViewModelHash();

  @$internal
  @override
  RideSearchViewModel create() => RideSearchViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RideSearchState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RideSearchState>(value),
    );
  }
}

String _$rideSearchViewModelHash() =>
    r'bcd0e38f94d0a57a77e1bf4c4a55ad7be1e65e2d';

/// Ride Search View Model

abstract class _$RideSearchViewModel extends $Notifier<RideSearchState> {
  RideSearchState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<RideSearchState, RideSearchState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<RideSearchState, RideSearchState>,
              RideSearchState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Single Ride Detail View Model

@ProviderFor(RideDetailViewModel)
final rideDetailViewModelProvider = RideDetailViewModelFamily._();

/// Single Ride Detail View Model
final class RideDetailViewModelProvider
    extends $AsyncNotifierProvider<RideDetailViewModel, RideModel?> {
  /// Single Ride Detail View Model
  RideDetailViewModelProvider._({
    required RideDetailViewModelFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'rideDetailViewModelProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rideDetailViewModelHash();

  @override
  String toString() {
    return r'rideDetailViewModelProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  RideDetailViewModel create() => RideDetailViewModel();

  @override
  bool operator ==(Object other) {
    return other is RideDetailViewModelProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rideDetailViewModelHash() =>
    r'd0d6b921afe2c16adaa617f9fc22eb4092dec3ad';

/// Single Ride Detail View Model

final class RideDetailViewModelFamily extends $Family
    with
        $ClassFamilyOverride<
          RideDetailViewModel,
          AsyncValue<RideModel?>,
          RideModel?,
          FutureOr<RideModel?>,
          String
        > {
  RideDetailViewModelFamily._()
    : super(
        retry: null,
        name: r'rideDetailViewModelProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Single Ride Detail View Model

  RideDetailViewModelProvider call(String rideId) =>
      RideDetailViewModelProvider._(argument: rideId, from: this);

  @override
  String toString() => r'rideDetailViewModelProvider';
}

/// Single Ride Detail View Model

abstract class _$RideDetailViewModel extends $AsyncNotifier<RideModel?> {
  late final _$args = ref.$arg as String;
  String get rideId => _$args;

  FutureOr<RideModel?> build(String rideId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<RideModel?>, RideModel?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<RideModel?>, RideModel?>,
              AsyncValue<RideModel?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

/// User's Rides Provider (as driver)

@ProviderFor(myRidesAsDriver)
final myRidesAsDriverProvider = MyRidesAsDriverFamily._();

/// User's Rides Provider (as driver)

final class MyRidesAsDriverProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideModel>>,
          List<RideModel>,
          FutureOr<List<RideModel>>
        >
    with $FutureModifier<List<RideModel>>, $FutureProvider<List<RideModel>> {
  /// User's Rides Provider (as driver)
  MyRidesAsDriverProvider._({
    required MyRidesAsDriverFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myRidesAsDriverProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myRidesAsDriverHash();

  @override
  String toString() {
    return r'myRidesAsDriverProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<RideModel>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<RideModel>> create(Ref ref) {
    final argument = this.argument as String;
    return myRidesAsDriver(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyRidesAsDriverProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myRidesAsDriverHash() => r'3c8f52a8143b6b23c2c59db7d2d7ad47f8795875';

/// User's Rides Provider (as driver)

final class MyRidesAsDriverFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<RideModel>>, String> {
  MyRidesAsDriverFamily._()
    : super(
        retry: null,
        name: r'myRidesAsDriverProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// User's Rides Provider (as driver)

  MyRidesAsDriverProvider call(String userId) =>
      MyRidesAsDriverProvider._(argument: userId, from: this);

  @override
  String toString() => r'myRidesAsDriverProvider';
}

/// User's Rides Stream Provider (as driver) - Real-time

@ProviderFor(myRidesAsDriverStream)
final myRidesAsDriverStreamProvider = MyRidesAsDriverStreamFamily._();

/// User's Rides Stream Provider (as driver) - Real-time

final class MyRidesAsDriverStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideModel>>,
          List<RideModel>,
          Stream<List<RideModel>>
        >
    with $FutureModifier<List<RideModel>>, $StreamProvider<List<RideModel>> {
  /// User's Rides Stream Provider (as driver) - Real-time
  MyRidesAsDriverStreamProvider._({
    required MyRidesAsDriverStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myRidesAsDriverStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myRidesAsDriverStreamHash();

  @override
  String toString() {
    return r'myRidesAsDriverStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RideModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideModel>> create(Ref ref) {
    final argument = this.argument as String;
    return myRidesAsDriverStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyRidesAsDriverStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myRidesAsDriverStreamHash() =>
    r'f60e94e4f91167f9f36c5a88de72d58ab497012a';

/// User's Rides Stream Provider (as driver) - Real-time

final class MyRidesAsDriverStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RideModel>>, String> {
  MyRidesAsDriverStreamFamily._()
    : super(
        retry: null,
        name: r'myRidesAsDriverStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// User's Rides Stream Provider (as driver) - Real-time

  MyRidesAsDriverStreamProvider call(String userId) =>
      MyRidesAsDriverStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'myRidesAsDriverStreamProvider';
}

/// User's Rides as Passenger Stream Provider

@ProviderFor(myRidesAsPassengerStream)
final myRidesAsPassengerStreamProvider = MyRidesAsPassengerStreamFamily._();

/// User's Rides as Passenger Stream Provider

final class MyRidesAsPassengerStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideModel>>,
          List<RideModel>,
          Stream<List<RideModel>>
        >
    with $FutureModifier<List<RideModel>>, $StreamProvider<List<RideModel>> {
  /// User's Rides as Passenger Stream Provider
  MyRidesAsPassengerStreamProvider._({
    required MyRidesAsPassengerStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'myRidesAsPassengerStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myRidesAsPassengerStreamHash();

  @override
  String toString() {
    return r'myRidesAsPassengerStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<RideModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideModel>> create(Ref ref) {
    final argument = this.argument as String;
    return myRidesAsPassengerStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is MyRidesAsPassengerStreamProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myRidesAsPassengerStreamHash() =>
    r'0839ae884645c1920dca8617f4776e51f6a762b5';

/// User's Rides as Passenger Stream Provider

final class MyRidesAsPassengerStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<RideModel>>, String> {
  MyRidesAsPassengerStreamFamily._()
    : super(
        retry: null,
        name: r'myRidesAsPassengerStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// User's Rides as Passenger Stream Provider

  MyRidesAsPassengerStreamProvider call(String userId) =>
      MyRidesAsPassengerStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'myRidesAsPassengerStreamProvider';
}

/// Nearby Rides Stream Provider

@ProviderFor(nearbyRides)
final nearbyRidesProvider = NearbyRidesFamily._();

/// Nearby Rides Stream Provider

final class NearbyRidesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideModel>>,
          List<RideModel>,
          Stream<List<RideModel>>
        >
    with $FutureModifier<List<RideModel>>, $StreamProvider<List<RideModel>> {
  /// Nearby Rides Stream Provider
  NearbyRidesProvider._({
    required NearbyRidesFamily super.from,
    required ({double latitude, double longitude}) super.argument,
  }) : super(
         retry: null,
         name: r'nearbyRidesProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$nearbyRidesHash();

  @override
  String toString() {
    return r'nearbyRidesProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  $StreamProviderElement<List<RideModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideModel>> create(Ref ref) {
    final argument = this.argument as ({double latitude, double longitude});
    return nearbyRides(
      ref,
      latitude: argument.latitude,
      longitude: argument.longitude,
    );
  }

  @override
  bool operator ==(Object other) {
    return other is NearbyRidesProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$nearbyRidesHash() => r'29c2605890770901bd81120b0ad349c05180f01c';

/// Nearby Rides Stream Provider

final class NearbyRidesFamily extends $Family
    with
        $FunctionalFamilyOverride<
          Stream<List<RideModel>>,
          ({double latitude, double longitude})
        > {
  NearbyRidesFamily._()
    : super(
        retry: null,
        name: r'nearbyRidesProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Nearby Rides Stream Provider

  NearbyRidesProvider call({
    required double latitude,
    required double longitude,
  }) => NearbyRidesProvider._(
    argument: (latitude: latitude, longitude: longitude),
    from: this,
  );

  @override
  String toString() => r'nearbyRidesProvider';
}

/// All Active Rides Stream Provider (for search screen)

@ProviderFor(activeRides)
final activeRidesProvider = ActiveRidesProvider._();

/// All Active Rides Stream Provider (for search screen)

final class ActiveRidesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<RideModel>>,
          List<RideModel>,
          Stream<List<RideModel>>
        >
    with $FutureModifier<List<RideModel>>, $StreamProvider<List<RideModel>> {
  /// All Active Rides Stream Provider (for search screen)
  ActiveRidesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'activeRidesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$activeRidesHash();

  @$internal
  @override
  $StreamProviderElement<List<RideModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<RideModel>> create(Ref ref) {
    return activeRides(ref);
  }
}

String _$activeRidesHash() => r'33d8e8142d6370fba56a524ba48ec7bf3df6ec2b';

/// Single Ride Stream Provider (for active ride screens)

@ProviderFor(rideStream)
final rideStreamProvider = RideStreamFamily._();

/// Single Ride Stream Provider (for active ride screens)

final class RideStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<RideModel?>,
          RideModel?,
          Stream<RideModel?>
        >
    with $FutureModifier<RideModel?>, $StreamProvider<RideModel?> {
  /// Single Ride Stream Provider (for active ride screens)
  RideStreamProvider._({
    required RideStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'rideStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$rideStreamHash();

  @override
  String toString() {
    return r'rideStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<RideModel?> $createElement($ProviderPointer pointer) =>
      $StreamProviderElement(pointer);

  @override
  Stream<RideModel?> create(Ref ref) {
    final argument = this.argument as String;
    return rideStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is RideStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$rideStreamHash() => r'683ccc87f0b20a3fa18f796774dc2cf3508a7759';

/// Single Ride Stream Provider (for active ride screens)

final class RideStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<RideModel?>, String> {
  RideStreamFamily._()
    : super(
        retry: null,
        name: r'rideStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Single Ride Stream Provider (for active ride screens)

  RideStreamProvider call(String rideId) =>
      RideStreamProvider._(argument: rideId, from: this);

  @override
  String toString() => r'rideStreamProvider';
}
