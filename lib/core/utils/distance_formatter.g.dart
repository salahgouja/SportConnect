// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'distance_formatter.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that exposes a distance formatting function using the saved unit.

@ProviderFor(distanceFormatter)
final distanceFormatterProvider = DistanceFormatterProvider._();

/// Provider that exposes a distance formatting function using the saved unit.

final class DistanceFormatterProvider
    extends
        $FunctionalProvider<
          String Function(double km),
          String Function(double km),
          String Function(double km)
        >
    with $Provider<String Function(double km)> {
  /// Provider that exposes a distance formatting function using the saved unit.
  DistanceFormatterProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'distanceFormatterProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$distanceFormatterHash();

  @$internal
  @override
  $ProviderElement<String Function(double km)> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  String Function(double km) create(Ref ref) {
    return distanceFormatter(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(String Function(double km) value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<String Function(double km)>(value),
    );
  }
}

String _$distanceFormatterHash() => r'58eb3b0aa4c4957f65f155ef623d5b9b97ab98ef';
