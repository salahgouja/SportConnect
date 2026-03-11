// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'driver_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ViewModel for all driver dashboard screens.
///
/// Aggregates all stream data so views only need to watch this single
/// provider — following Flutter Architecture's MVVM recommendation that
/// views should not reference repository / stream providers directly.
///
/// Design notes:
/// - Data streams are subscribed via [ref.listen] so that build() is NOT
///   re-called on each emission (which would reset [isLoading]/[errorMessage]).
/// - The state is mutated granularly inside the listeners, preserving transient
///   action state across Firestore updates.

@ProviderFor(DriverViewModel)
final driverViewModelProvider = DriverViewModelProvider._();

/// ViewModel for all driver dashboard screens.
///
/// Aggregates all stream data so views only need to watch this single
/// provider — following Flutter Architecture's MVVM recommendation that
/// views should not reference repository / stream providers directly.
///
/// Design notes:
/// - Data streams are subscribed via [ref.listen] so that build() is NOT
///   re-called on each emission (which would reset [isLoading]/[errorMessage]).
/// - The state is mutated granularly inside the listeners, preserving transient
///   action state across Firestore updates.
final class DriverViewModelProvider
    extends $NotifierProvider<DriverViewModel, DriverState> {
  /// ViewModel for all driver dashboard screens.
  ///
  /// Aggregates all stream data so views only need to watch this single
  /// provider — following Flutter Architecture's MVVM recommendation that
  /// views should not reference repository / stream providers directly.
  ///
  /// Design notes:
  /// - Data streams are subscribed via [ref.listen] so that build() is NOT
  ///   re-called on each emission (which would reset [isLoading]/[errorMessage]).
  /// - The state is mutated granularly inside the listeners, preserving transient
  ///   action state across Firestore updates.
  DriverViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'driverViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$driverViewModelHash();

  @$internal
  @override
  DriverViewModel create() => DriverViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DriverState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DriverState>(value),
    );
  }
}

String _$driverViewModelHash() => r'b856efda9bed5cfb6c9b10523d1bce3be6aec646';

/// ViewModel for all driver dashboard screens.
///
/// Aggregates all stream data so views only need to watch this single
/// provider — following Flutter Architecture's MVVM recommendation that
/// views should not reference repository / stream providers directly.
///
/// Design notes:
/// - Data streams are subscribed via [ref.listen] so that build() is NOT
///   re-called on each emission (which would reset [isLoading]/[errorMessage]).
/// - The state is mutated granularly inside the listeners, preserving transient
///   action state across Firestore updates.

abstract class _$DriverViewModel extends $Notifier<DriverState> {
  DriverState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<DriverState, DriverState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<DriverState, DriverState>,
              DriverState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
