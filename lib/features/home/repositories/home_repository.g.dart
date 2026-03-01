// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'home_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Stream provider for hotspots

@ProviderFor(hotspotsStream)
final hotspotsStreamProvider = HotspotsStreamProvider._();

/// Stream provider for hotspots

final class HotspotsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<Hotspot>>,
          List<Hotspot>,
          Stream<List<Hotspot>>
        >
    with $FutureModifier<List<Hotspot>>, $StreamProvider<List<Hotspot>> {
  /// Stream provider for hotspots
  HotspotsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'hotspotsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$hotspotsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<Hotspot>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<Hotspot>> create(Ref ref) {
    return hotspotsStream(ref);
  }
}

String _$hotspotsStreamHash() => r'862504d1ce7d996e99f1bc732ed504e0b4a1bb37';
