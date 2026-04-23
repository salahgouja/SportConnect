// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider for map style preference

@ProviderFor(MapStyleProvider)
final mapStyleProvider = MapStyleProviderProvider._();

/// Provider for map style preference
final class MapStyleProviderProvider
    extends $AsyncNotifierProvider<MapStyleProvider, String> {
  /// Provider for map style preference
  MapStyleProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'mapStyleProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$mapStyleProviderHash();

  @$internal
  @override
  MapStyleProvider create() => MapStyleProvider();
}

String _$mapStyleProviderHash() => r'44abf4c731903bb9c4811c98331e75252df2f287';

/// Provider for map style preference

abstract class _$MapStyleProvider extends $AsyncNotifier<String> {
  FutureOr<String> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<String>, String>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<String>, String>,
              AsyncValue<String>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for current app locale
///
/// Reads from SettingsRepository and provides reactive locale state.
/// Returns null if user hasn't set a preference (app will use system locale).

@ProviderFor(LocaleProvider)
final localeProvider = LocaleProviderProvider._();

/// Provider for current app locale
///
/// Reads from SettingsRepository and provides reactive locale state.
/// Returns null if user hasn't set a preference (app will use system locale).
final class LocaleProviderProvider
    extends $AsyncNotifierProvider<LocaleProvider, Locale?> {
  /// Provider for current app locale
  ///
  /// Reads from SettingsRepository and provides reactive locale state.
  /// Returns null if user hasn't set a preference (app will use system locale).
  LocaleProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'localeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$localeProviderHash();

  @$internal
  @override
  LocaleProvider create() => LocaleProvider();
}

String _$localeProviderHash() => r'3f82e0260a23b685391c4b502068892a4a6d6532';

/// Provider for current app locale
///
/// Reads from SettingsRepository and provides reactive locale state.
/// Returns null if user hasn't set a preference (app will use system locale).

abstract class _$LocaleProvider extends $AsyncNotifier<Locale?> {
  FutureOr<Locale?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Locale?>, Locale?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Locale?>, Locale?>,
              AsyncValue<Locale?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for push notifications setting

@ProviderFor(NotificationsEnabledProvider)
final notificationsEnabledProvider = NotificationsEnabledProviderProvider._();

/// Provider for push notifications setting
final class NotificationsEnabledProviderProvider
    extends $AsyncNotifierProvider<NotificationsEnabledProvider, bool> {
  /// Provider for push notifications setting
  NotificationsEnabledProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsEnabledProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsEnabledProviderHash();

  @$internal
  @override
  NotificationsEnabledProvider create() => NotificationsEnabledProvider();
}

String _$notificationsEnabledProviderHash() =>
    r'08f0cd8bde7e49b4cd9cd7ae9ea6e349ee5ecd83';

/// Provider for push notifications setting

abstract class _$NotificationsEnabledProvider extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for ride reminders setting

@ProviderFor(RideRemindersProvider)
final rideRemindersProvider = RideRemindersProviderProvider._();

/// Provider for ride reminders setting
final class RideRemindersProviderProvider
    extends $AsyncNotifierProvider<RideRemindersProvider, bool> {
  /// Provider for ride reminders setting
  RideRemindersProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rideRemindersProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rideRemindersProviderHash();

  @$internal
  @override
  RideRemindersProvider create() => RideRemindersProvider();
}

String _$rideRemindersProviderHash() =>
    r'62d2dd1c2ada09172190a99396af350dcc61baa4';

/// Provider for ride reminders setting

abstract class _$RideRemindersProvider extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for chat notifications setting

@ProviderFor(ChatNotificationsProvider)
final chatNotificationsProvider = ChatNotificationsProviderProvider._();

/// Provider for chat notifications setting
final class ChatNotificationsProviderProvider
    extends $AsyncNotifierProvider<ChatNotificationsProvider, bool> {
  /// Provider for chat notifications setting
  ChatNotificationsProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'chatNotificationsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$chatNotificationsProviderHash();

  @$internal
  @override
  ChatNotificationsProvider create() => ChatNotificationsProvider();
}

String _$chatNotificationsProviderHash() =>
    r'659e4df33c1d8986c09d8b3ee0ddf697c3ae4ac7';

/// Provider for chat notifications setting

abstract class _$ChatNotificationsProvider extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for show location setting

@ProviderFor(ShowLocationProvider)
final showLocationProvider = ShowLocationProviderProvider._();

/// Provider for show location setting
final class ShowLocationProviderProvider
    extends $AsyncNotifierProvider<ShowLocationProvider, bool> {
  /// Provider for show location setting
  ShowLocationProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'showLocationProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$showLocationProviderHash();

  @$internal
  @override
  ShowLocationProvider create() => ShowLocationProvider();
}

String _$showLocationProviderHash() =>
    r'6a3e376ab1224107d023d4aa57611f1c3c5e87c9';

/// Provider for show location setting

abstract class _$ShowLocationProvider extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Provider for public profile setting

@ProviderFor(PublicProfileProvider)
final publicProfileProvider = PublicProfileProviderProvider._();

/// Provider for public profile setting
final class PublicProfileProviderProvider
    extends $AsyncNotifierProvider<PublicProfileProvider, bool> {
  /// Provider for public profile setting
  PublicProfileProviderProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'publicProfileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$publicProfileProviderHash();

  @$internal
  @override
  PublicProfileProvider create() => PublicProfileProvider();
}

String _$publicProfileProviderHash() =>
    r'7453b0a49a462c6b63e74ca7974d244732cb36a5';

/// Provider for public profile setting

abstract class _$PublicProfileProvider extends $AsyncNotifier<bool> {
  FutureOr<bool> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<bool>, bool>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<bool>, bool>,
              AsyncValue<bool>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(SavedCredentialsNotifier)
final savedCredentialsProvider = SavedCredentialsNotifierProvider._();

final class SavedCredentialsNotifierProvider
    extends $AsyncNotifierProvider<SavedCredentialsNotifier, SavedCredentials> {
  SavedCredentialsNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'savedCredentialsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$savedCredentialsNotifierHash();

  @$internal
  @override
  SavedCredentialsNotifier create() => SavedCredentialsNotifier();
}

String _$savedCredentialsNotifierHash() =>
    r'6f57c0077f6d0f9fff1cc83ce8e0a0464adc79a8';

abstract class _$SavedCredentialsNotifier
    extends $AsyncNotifier<SavedCredentials> {
  FutureOr<SavedCredentials> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<SavedCredentials>, SavedCredentials>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<SavedCredentials>, SavedCredentials>,
              AsyncValue<SavedCredentials>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}
