// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_repository.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(eventRepository)
final eventRepositoryProvider = EventRepositoryProvider._();

final class EventRepositoryProvider
    extends
        $FunctionalProvider<
          IEventRepository,
          IEventRepository,
          IEventRepository
        >
    with $Provider<IEventRepository> {
  EventRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventRepositoryProvider',
        isAutoDispose: false,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventRepositoryHash();

  @$internal
  @override
  $ProviderElement<IEventRepository> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  IEventRepository create(Ref ref) {
    return eventRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(IEventRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<IEventRepository>(value),
    );
  }
}

String _$eventRepositoryHash() => r'95a12c0377978d44311c3eba8f62d9e68150521a';
