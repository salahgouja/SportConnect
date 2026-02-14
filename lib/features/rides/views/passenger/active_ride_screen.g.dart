// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'active_ride_screen.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stream provider for active ride - uses repository (MVVM pattern)

@ProviderFor(activeRideStream)
final activeRideStreamProvider = ActiveRideStreamFamily._();

/// Stream provider for active ride - uses repository (MVVM pattern)

final class ActiveRideStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<RideModel?>,
          RideModel?,
          Stream<RideModel?>
        >
    with $FutureModifier<RideModel?>, $StreamProvider<RideModel?> {
  /// Stream provider for active ride - uses repository (MVVM pattern)
  ActiveRideStreamProvider._({
    required ActiveRideStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'activeRideStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$activeRideStreamHash();

  @override
  String toString() {
    return r'activeRideStreamProvider'
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
    return activeRideStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is ActiveRideStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$activeRideStreamHash() => r'a4986e747470308caf43b5df861eff7736ca989d';

/// Stream provider for active ride - uses repository (MVVM pattern)

final class ActiveRideStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<RideModel?>, String> {
  ActiveRideStreamFamily._()
    : super(
        retry: null,
        name: r'activeRideStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Stream provider for active ride - uses repository (MVVM pattern)

  ActiveRideStreamProvider call(String rideId) =>
      ActiveRideStreamProvider._(argument: rideId, from: this);

  @override
  String toString() => r'activeRideStreamProvider';
}
