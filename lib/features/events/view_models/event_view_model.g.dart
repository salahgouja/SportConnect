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
    r'6101429a36221a59cd35f07d30f49231c2998506';

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

@ProviderFor(EventDetailViewModel)
final eventDetailViewModelProvider = EventDetailViewModelProvider._();

final class EventDetailViewModelProvider
    extends $NotifierProvider<EventDetailViewModel, EventDetailState> {
  EventDetailViewModelProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'eventDetailViewModelProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$eventDetailViewModelHash();

  @$internal
  @override
  EventDetailViewModel create() => EventDetailViewModel();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(EventDetailState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<EventDetailState>(value),
    );
  }
}

String _$eventDetailViewModelHash() =>
    r'30ce2cc1c3f8b98ec17b43a673ca0288a5314cec';

abstract class _$EventDetailViewModel extends $Notifier<EventDetailState> {
  EventDetailState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<EventDetailState, EventDetailState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<EventDetailState, EventDetailState>,
              EventDetailState,
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

@ProviderFor(eventsByCreatorStream)
final eventsByCreatorStreamProvider = EventsByCreatorStreamFamily._();

final class EventsByCreatorStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventModel>>,
          List<EventModel>,
          Stream<List<EventModel>>
        >
    with $FutureModifier<List<EventModel>>, $StreamProvider<List<EventModel>> {
  EventsByCreatorStreamProvider._({
    required EventsByCreatorStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventsByCreatorStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventsByCreatorStreamHash();

  @override
  String toString() {
    return r'eventsByCreatorStreamProvider'
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
    final argument = this.argument as String;
    return eventsByCreatorStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventsByCreatorStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventsByCreatorStreamHash() =>
    r'28278a027f4d4985937a30756f67e9fa819fb143';

final class EventsByCreatorStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<EventModel>>, String> {
  EventsByCreatorStreamFamily._()
    : super(
        retry: null,
        name: r'eventsByCreatorStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventsByCreatorStreamProvider call(String creatorId) =>
      EventsByCreatorStreamProvider._(argument: creatorId, from: this);

  @override
  String toString() => r'eventsByCreatorStreamProvider';
}

@ProviderFor(joinedEventsStream)
final joinedEventsStreamProvider = JoinedEventsStreamFamily._();

final class JoinedEventsStreamProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<EventModel>>,
          List<EventModel>,
          Stream<List<EventModel>>
        >
    with $FutureModifier<List<EventModel>>, $StreamProvider<List<EventModel>> {
  JoinedEventsStreamProvider._({
    required JoinedEventsStreamFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'joinedEventsStreamProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$joinedEventsStreamHash();

  @override
  String toString() {
    return r'joinedEventsStreamProvider'
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
    final argument = this.argument as String;
    return joinedEventsStream(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is JoinedEventsStreamProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$joinedEventsStreamHash() =>
    r'c7512c9c41fc741860321c32040eb9d42a3d9ca5';

final class JoinedEventsStreamFamily extends $Family
    with $FunctionalFamilyOverride<Stream<List<EventModel>>, String> {
  JoinedEventsStreamFamily._()
    : super(
        retry: null,
        name: r'joinedEventsStreamProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  JoinedEventsStreamProvider call(String userId) =>
      JoinedEventsStreamProvider._(argument: userId, from: this);

  @override
  String toString() => r'joinedEventsStreamProvider';
}

@ProviderFor(eventById)
final eventByIdProvider = EventByIdFamily._();

final class EventByIdProvider
    extends
        $FunctionalProvider<
          AsyncValue<EventModel?>,
          EventModel?,
          FutureOr<EventModel?>
        >
    with $FutureModifier<EventModel?>, $FutureProvider<EventModel?> {
  EventByIdProvider._({
    required EventByIdFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'eventByIdProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$eventByIdHash();

  @override
  String toString() {
    return r'eventByIdProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<EventModel?> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<EventModel?> create(Ref ref) {
    final argument = this.argument as String;
    return eventById(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is EventByIdProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$eventByIdHash() => r'c710e4d543bcdb8d4a0e45847fe89419c53ce4b4';

final class EventByIdFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<EventModel?>, String> {
  EventByIdFamily._()
    : super(
        retry: null,
        name: r'eventByIdProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  EventByIdProvider call(String eventId) =>
      EventByIdProvider._(argument: eventId, from: this);

  @override
  String toString() => r'eventByIdProvider';
}
