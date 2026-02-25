// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'ride_request_service.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Ride request service - handles business logic
/// Moved from model extensions to proper service layer

@ProviderFor(RideRequestService)
final rideRequestServiceProvider = RideRequestServiceProvider._();

/// Ride request service - handles business logic
/// Moved from model extensions to proper service layer
final class RideRequestServiceProvider
    extends $AsyncNotifierProvider<RideRequestService, void> {
  /// Ride request service - handles business logic
  /// Moved from model extensions to proper service layer
  RideRequestServiceProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideRequestServiceProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideRequestServiceHash();

  @$internal
  @override
  RideRequestService create() => RideRequestService();
}

String _$rideRequestServiceHash() =>
    r'03efb407834aa265fb58700f1577ffdc83555e3b';

/// Ride request service - handles business logic
/// Moved from model extensions to proper service layer

abstract class _$RideRequestService extends $AsyncNotifier<void> {
  FutureOr<void> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<void>, void>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<void>, void>,
              AsyncValue<void>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
