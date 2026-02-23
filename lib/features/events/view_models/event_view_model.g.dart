// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'event_view_model.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(EventSelectionViewModel)
final eventSelectionViewModelProvider = EventSelectionViewModelProvider._();

final class EventSelectionViewModelProvider
    extends $NotifierProvider<EventSelectionViewModel, EventSelectionState> {
  EventSelectionViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventSelectionViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventSelectionViewModelHash();

  @$internal
  @override
  EventSelectionViewModel create() => EventSelectionViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventSelectionState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventSelectionState>(value),
    );
  }
}

String _$eventSelectionViewModelHash() =>
    r'8388c0cd1be63a0809583662e1bdcf9599ef09a9';

abstract class _$EventSelectionViewModel
    extends $Notifier<EventSelectionState> {
  EventSelectionState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EventSelectionState, EventSelectionState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EventSelectionState, EventSelectionState>,
              EventSelectionState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(upcomingEventsStream)
final upcomingEventsStreamProvider = UpcomingEventsStreamProvider._();

final class UpcomingEventsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventModel>>,
          List<EventModel>,
          Stream<List<EventModel>>
        >
    with $FutureModifier<List<EventModel>>, $StreamProvider<List<EventModel>> {
  UpcomingEventsStreamProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'upcomingEventsStreamProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$upcomingEventsStreamHash();

  @$internal
  @override
  $StreamProviderElement<List<EventModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<EventModel>> create(Ref ref) {
    return upcomingEventsStream(ref);
  }
}

String _$upcomingEventsStreamHash() =>
    r'8c8ed02563a5ddd1ec266a9f650ddf2f72327497';

@ProviderFor(eventsByTypeStream)
final eventsByTypeStreamProvider = EventsByTypeStreamFamily._();

final class EventsByTypeStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventModel>>,
          List<EventModel>,
          Stream<List<EventModel>>
        >
    with $FutureModifier<List<EventModel>>, $StreamProvider<List<EventModel>> {
  EventsByTypeStreamProvider._({
    required EventsByTypeStreamFamily super.from,
    required EventType super.argument,
  }) : super(
         retry: null,
         name: r'eventsByTypeStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventsByTypeStreamHash();

  @override
  String toString() {
    return r'eventsByTypeStreamProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $StreamProviderElement<List<EventModel>> $createElement(
    $ProviderPointer pointer,
  ) => $StreamProviderElement(pointer);

  @override
  Stream<List<EventModel>> create(Ref ref) {
    final argument = this.argument as EventType;
    return eventsByTypeStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventsByTypeStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventsByTypeStreamHash() =>
    r'5b2b2ae5aafee87bfa2bfa209018f271d8aa3244';

final class EventsByTypeStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<EventModel>>, EventType> {
  EventsByTypeStreamFamily._()
    : super(
        retry: null,
        name: r'eventsByTypeStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventsByTypeStreamProvider call(EventType type) =>
      EventsByTypeStreamProvider._(argument: type, from: this);

  @override
  String toString() => r'eventsByTypeStreamProvider';
}
