// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rideRepository)
final rideRepositoryProvider = RideRepositoryProvider._();

final class RideRepositoryProvider
    extends
        $FunctionalProvider<IRideRepository, IRideRepository, IRideRepository>
    with $Provider<IRideRepository> {
  RideRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideRepositoryProvider',
        isAutoDispose: true,
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

String _$rideRepositoryHash() => r'f2c5fa146196cddf9e4505d79ba9c8f5114212d2';
